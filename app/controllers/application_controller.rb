class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	helper_method :current_share_user

	before_filter :store_location

	def store_location
		# store last url - this is needed for post-login redirect to whatever the user last visited.
		return unless request.get? 
			if (request.path != "/users/sign_in" &&
				request.path != "/users/sign_up" &&
				request.path != "/users/password/new" &&
				request.path != "/users/sign_out" &&
				request.path != "/users/confirmation" &&
				!request.xhr?) # don't store ajax calls
			session[:previous_url] = request.fullpath
		end
	end

	def after_sign_in_path_for(user)
		session[:previous_url] || share_index_path(current_user)
	end

	#I dislike this implementation. I would prefer to use two seperate functions with the same name and different args.
	#However, that throws errors on some specs.
	def current_share_user(share_id=nil)
		if share_id.nil? == true
			#This implementation locks the return to a given user, which prevents other users from seeing another's data
			@current_share_user = ShareUser.where("id = ? AND user_id = ?", params[:share_user_id], current_user.id)[0]
			
			#The below may not be needed; more research is required to determine this.
			if @current_share_user.nil? == true
				#Using this method as the primary adds security by returning nil if the user does not actually possess the share_user given as a param.
				@current_share_user = ShareUser.where("share_id = ? AND user_id = ?", params[:id], current_user.id)[0]
			end

			return @current_share_user
		else
			@current_share_user = ShareUser.where("share_id = ? AND user_id = ?", share_id, current_user.id)[0]
			return @current_share_user
		end
	end

	def require_share_user
		if current_share_user == nil
			flash[:error] = "You either lack permission to view that page, or have not selected a group yet. Please select a group before continuing."
			redirect_to share_index_path
		end
	end
end
