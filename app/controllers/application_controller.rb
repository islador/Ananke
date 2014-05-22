class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

	def after_sign_in_path_for(user)
		share_index_path(current_user)
	end

	def current_share_user
		@current_share_user = ShareUser.where("id = ?", params[:share_user_id])[0]
		#puts "CurrentShareUser: " + @current_share_user.apis.count.to_s
		#The below may not be needed; more research is required to determine this.
		if @current_share_user.nil? == true
			@current_share_user = ShareUser.where("share_id = ? AND user_id = ?", params[:id], current_user.id)[0]
		end
		return @current_share_user
		#@current_share_user = ShareUser.where("share_id = ? AND user_id = ?", session[:share_id], current_user.id)[0]
	end

	def require_share_user
		if session[:share_id] == nil
			flash[:error] = "Please select a group before continuing."
			redirect_to share_index_path
		end
	end
end
