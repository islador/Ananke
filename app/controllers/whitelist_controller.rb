class WhitelistController < ApplicationController
	before_action :authenticate_user!

	#CRUD methods

	def create
		Whitelist.create(name: params[:entity_name], entity_type: params[:entity_type], source_type: 2, source_user: current_user.id)
		render nothing: true
	end

	def destroy
		Whitelist.where("id = ?", params[:id])[0].destroy
		render nothing: true
	end

	def begin_api_pull
		api = Api.where("id = ?", params[:api_id])[0]
		if api.nil? == false
			ApiCorpContactPullWorker.perform_async(api.id)
			render :json => "API queued for contact processing"
		else
			render :json => "Invalid API"
		end
	end

	#Display methods
	def white_list
		@wl = Whitelist.all
		@corp_apis = current_user.apis.where("ananke_type = 1 AND active = true")
		@active_pull_apis = Api.joins(:whitelist_api_connections).uniq
		@user_char_names = []
		@active_pull_apis.each do |api|
			@user_char_names.push(api.user.main_char_name)
		end
	end

	def white_list_log
		@wll = WhitelistLog.all
	end
end
