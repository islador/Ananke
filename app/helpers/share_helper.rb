module ShareHelper
	def current_share
		@current_share = Share.where("id = ?", session[:share_id])[0]
	end
end
