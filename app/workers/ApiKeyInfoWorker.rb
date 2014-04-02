class ApiKeyInfoWorker
	include Sidekiq::Worker

	def perform(keyID, vCode)
		#We want this to hit the API and then hit the database directly. That means it will likely need to be controller fired, not API model fired.

		#Build the API object
		api = Eve::API.new(:key_id => keyID, :v_code => vCode)

		#Query the API
		result = api.account.apikeyinfo
		#Check for Corporation status
		if(result.key.type == "Corporation")
			#If found, extract the corporation name from the only character in the list.
			corp_name = result.key.characters[0].corporationName
			api = Api.where("key_id = ?", keyID)[0]
			api.main_entity = corp_name
			api.save!
		end
	end
end