class ApiKeyInfoWorker
	include Sidekiq::Worker

	def perform(keyID, vCode)
		#We want this to hit the API and then hit the database directly. That means it will likely need to be controller fired, not API model fired.
		#retrieve the current API record from the database
		ananke_api = Api.where("key_id = ?", keyID)[0]
		#Build the API object
		eve_api = Eve::API.new(:key_id => keyID, :v_code => vCode)

		#Query the API
		result = eve_api.account.apikeyinfo
		#Check for Corporation status
		if(result.key.type == "Corporation")
			#If found, extract the corporation name from the only character in the list.
			corp_name = result.key.characters[0].corporationName

			ananke_api.main_entity = corp_name
			ananke_api.save!	
		end

		if(result.key.type == "Account" || result.key.type == "Character")
			#Iterate through the returned characters
			result.key.characters.each do |c|
				#Insert each into the database.
				toon = ananke_api.characters.build(name: c.characterName, characterID: c.characterID, corporationName: c.corporationName, corporationID: c.corporationID, allianceName: c.allianceName, allianceID: c.allianceID, factionName: c.factionName, factionID: c.factionID)
				if toon.valid? == true
					toon.save!
				end
			end
		end

		#if(result.key.type == "Character")
			#Key with a single character.
		#end

		#Save the API after all changes have been made
		
	end
end