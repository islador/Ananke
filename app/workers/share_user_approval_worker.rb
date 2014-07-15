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

				#Update the character's affiliations

				if(result.key.type == "Corporation")
					raise ArgumentError "Corporation APIs not allowed."
				else
					allianceName = ""
					factionName = ""

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

						#Retrieve the character from the database
						character = ananke_api.characters.where("ccp_character_id = ?", c.characterID)[0]

						#If the character cannot be found
						if character.nil? == true
							#Insert it into the database
							toon = ananke_api.characters.build(name: c.characterName, ccp_character_id: c.characterID, corporationName: c.corporationName, ccp_corporation_id: c.corporationID, allianceName: allianceName, ccp_alliance_id: c.allianceID, factionName: factionName, ccp_faction_id: c.factionID, share_id: ananke_api.share_user.share_id)
							if toon.valid? == true
								#puts "Saving: " + toon.ccp_character_id.to_s
								toon.save
							else
								#puts toon.ccp_character_id
								puts toon.errors.messages
							end
						#Otherwise
						else
							#Update the character's affiliations
							if character.name != c.characterName
								character.name = c.characterName
							end
							if character.ccp_corporation_id != c.corporationID
								character.ccp_corporation_id = c.corporationID
								character.corporationName = c.corporationName
							end
							if character.ccp_alliance_id != c.allianceID
								character.ccp_alliance_id = c.allianceID
								character.allianceName = allianceName
							end
							if character.ccp_faction_id != c.factionID
								character.ccp_faction_id = c.factionID
								character.factionName = factionName
							end

							#If the character is the main, attempt to approve the share_user
							if character.main == true
								share_user = ananke_api.share_user
								if character.approve_character? == true
									share_user.approved = true
								else
									share_user.approved = false
								end
								share_user.save
							end
							#Don't forget to save the character.
							character.save
						end
					end
				end

			
			#If authentication error
			rescue Eve::Errors::AuthenticationError => e
				#Set the API to inactive
				ananke_api.active = false

				#Disapprove the API's share_user.
				ananke_api.share_user.approved = false
				ananke_api.share_user.save
			end
			ananke_api.save
		end
	end
end