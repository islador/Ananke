class ApiKeyInfoWorker
	include Sidekiq::Worker

	def perform(id)
		#We want this to hit the API and then hit the database directly. That means it will likely need to be controller fired, not API model fired.
		#retrieve the current API record from the database, this assumes key_id is unique and is stupid because key_id is share scoped, this should be using api ids directly like everything else.
		ananke_api = Api.where("id = ?", id)[0]
		#Build the API object
		eve_api = Eve::API.new(:key_id => ananke_api.key_id, :v_code => ananke_api.v_code)

		begin
			#Query the API
			result = eve_api.account.apikeyinfo
			ananke_api.active = true
			#Check for Corporation status
			if(result.key.type == "Corporation")
				#If found, extract the corporation name from the only character in the list.
				corp_name = result.key.characters[0].corporationName
				#Set the main_entity_name to the corporation name.
				ananke_api.main_entity_name = corp_name
				#Set the ananke_type to corporation
				ananke_api.ananke_type = 1;	
			end
			allianceName = ""
			factionName = ""
			if(result.key.type == "Account" || result.key.type == "Character")
				#Set the ananke_type to general
				ananke_api.ananke_type = 2;
				#Iterate through the returned characters
				result.key.characters.each do |c|
					if(c.allianceName == false)
						allianceName = nil
					else
						allianceName = c.allianceName
					end
					if(c.factionName == false)
						factionName = nil
					else
						factionName = c.factionName
					end
					#puts "allianceName: #{c.allianceName}"
					#puts "factionName: #{c.factionName}"
					#Insert each into the database.
					toon = ananke_api.characters.build(name: c.characterName, ccp_character_id: c.characterID, corporationName: c.corporationName, ccp_corporation_id: c.corporationID, allianceName: allianceName, ccp_alliance_id: c.allianceID, factionName: factionName, ccp_faction_id: c.factionID, share_id: ananke_api.share_user.share_id)
					if toon.valid? == true
						#puts "Saving: " + toon.ccp_character_id.to_s
						toon.save!
					else
						puts toon.errors.messages
					end
				end
			end
		rescue Eve::Errors::AuthenticationError => e
			ananke_api.active = false
		end

		#Save the API after all changes have been made
		ananke_api.save!
	end
end