class WhitelistController < ApplicationController
	before_action :authenticate_user!, :require_share_user

	#CRUD methods

	def create
		Whitelist.create(name: params[:entity_name], entity_type: params[:entity_type], source_type: 2, source_share_user: current_share_user.id, share_id: current_share_user.share_id)
		render nothing: true
	end

	def destroy
		Whitelist.where("id = ?", params[:id])[0].destroy
		render nothing: true
	end

	#Display methods
	def white_list
		csu = current_share_user
		@wl = Whitelist.where("share_id = ?", csu.share_id)

		#Build the source_share_user names
		@source_share_user_names = {}

		values = Whitelist.where("share_id =?", csu.share_id).pluck("source_share_user").uniq
		names = ShareUser.where(id: values).pluck("main_char_name")
		values.each do |val|
			@source_share_user_names.store(names[values.index(val)].to_sym, val)
		end

		@active_pull_apis = Api.joins(:whitelist_api_connections).where("share_id = ?", csu.share_id).uniq
		@user_char_names = []
		@active_pull_apis.each do |api|
			@user_char_names.push(api.share_user.main_char_name)
		end
	end

	def retrieve_pullable_apis
		invalid_ids = Api.joins(:whitelist_api_connections).where("share_id = ?", current_share_user.share_id).uniq
		#http://stackoverflow.com/a/19984066
		@valid_corp_apis = current_share_user.apis.where.not(id: invalid_ids).where("ananke_type = 1 AND active = true")
		
		respond_to do |format|
			format.js
		end
	end

	def white_list_log
		@wll = WhitelistLog.where("share_id = ?", current_share_user.share_id)
	end
end
