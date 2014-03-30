class WhitelistController < ApplicationController
	before_action :authenticate_user!

	#CRUD methods

	def create
	end

	def destroy
		Whitelist.where("id = ?", params[:id])[0].destroy
		render nothing: true #Probably need to reload the table somehow instead of rendering nothing
	end

	#Display methods
	def white_list
		@wl = Whitelist.all
	end

	def white_list_log
		@wll = WhitelistLog.all
	end
end
