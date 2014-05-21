module ShareHelper
	def current_share
		@current_share = Share.where("id = ?", session[:share_id])[0]
	end

	def current_share_user
		@current_share_user = ShareUser.where("share_id = ? AND user_id = ?", session[:share_id], current_user.id)[0]
	end
end
