class ShareMailer < ActionMailer::Base
	default from: 'share-management@ananke.pw'

	def user_limit_exceeded(share_user)
		@share = share_user.share
		@owner = User.find(@share.owner_id)
		@share_user = share_user
		@user = @share_user.user
		
		mail(to: @owner.email, subject: "Ananke Share #{@share.name} User Limit Reached - #{@share_user.main_char_name} can't register")
	end
end
