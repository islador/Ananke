class ShareUserApprovalWorker
	include Sidekiq::Worker

	def perform(id)
		#share = Share.find(id)
		#Collect the APIs from the share.
		apis = Api.where("active = true AND main = true").joins(:share_user).where("share_id = ?", id).readonly(false)
		#Joins return a read only record, so I can't save them. This is solved by using a find_by_sql statement.
		#apis = Api.find_by_sql("SELECT * FROM apis INNER JOIN share_users ON share_users.id=apis.share_user_id WHERE active = true AND main = true AND share_id = #{id}")

		apis.each do |ananke_api|
			eve_api = Eve::API.new(:key_id => ananke_api.key_id, :v_code => ananke_api.v_code)

			#Query the API
			begin
				result = eve_api.account.apikeyinfo
			#If authentication error
			rescue Eve::Errors::AuthenticationError => e
				#Set the API to inactive
				ananke_api.active = false

				#Disapprove the API's share_user.
				ananke_api.share_user.approved = false
				ananke_api.share_user.save!
			end
			ananke_api.save!
		end
	end
end