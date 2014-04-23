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

	#Display methods
	def white_list
		@wl = Whitelist.all
		@active_pull_apis = Api.joins(:whitelist_api_connections).uniq
		@user_char_names = []
		@active_pull_apis.each do |api|
			@user_char_names.push(api.user.main_char_name)
		end
	end

	def retrieve_pullable_apis
		invalid_ids = Api.joins(:whitelist_api_connections).uniq
		#http://stackoverflow.com/a/19984066
		@corp_apis = current_user.apis.where.not(id: invalid_ids).where("ananke_type = 1 AND active = true")
		render nothing: true
	end

	def white_list_log
		@wll = WhitelistLog.all
	end
end
