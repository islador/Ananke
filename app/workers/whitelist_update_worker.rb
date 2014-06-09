class WhitelistUpdateWorker
	include Sidekiq::Worker
	#Update all of the api sourced whitelist entities belonging to the specified share.
	def perform(share_id)
		#Retrieve the IDs for each whitelist api connection
		wac_ids = WhitelistApiConnection.where("share_id = ?", share_id).pluck("id")
		#Retrieve all of the APIs with active pulls on this share from the database.
		apis = Api.joins(:whitelist_api_connections).where("share_id = ?", share_id)
		#puts apis.count
		#Iterate through each API
		apis.each do |ananke_api|
			raise ArgumentError, "Api must be a corporation API." if ananke_api.ananke_type != 1
			raise ArgumentError, "Api must be active." if ananke_api.active != true

			#Construct an eve api with the eve gem
			eve_api = Eve::API.new(:key_id => ananke_api.key_id, :v_code => ananke_api.v_code)

			#Query the API
			result = eve_api.corporation.contact_list

			#Iterate through each contact
			result.corporateContactList.each do |contact|
				contact_type = 0
				#Process the contact's contactTypeID
				if contact.contactTypeID == 2
					contact_type = 2
				elsif contact.contactTypeID == 16159
					contact_type = 1
				elsif contact.contactTypeID >= 1370 && contact.contactTypeID <= 1390
					contact_type = 4
				else
					contact_type = 3
				end
				

				if contact.standing >= ananke_api.whitelist_standings
					whitelist_entity = Whitelist.where("name = ?", contact.contactName)[0]
					#If this contact does not exist on the whitelist.  
					if whitelist_entity.nil? == true
						#Create a whitelist entity from it
						new_entity = Whitelist.create(name: contact.contactName, entity_type: contact_type, source_type: 1, source_share_user: ananke_api.share_user.id, standing: contact.standing)

						#and create a connection between that entity and the source API
						ananke_api.whitelist_api_connections.create(whitelist_id: new_entity.id)
						#No need to remove the new wac's id from the wac_ids array because it was never there.
					else
						#Check the entity's standings and see if they've changed.
						if contact.standing != whitelist_entity.standing
							#If they've changed, update them with the new data from the API
							whitelist_entity.standing = contact.standing
						end
						#Remove the wac's id from the wac_ids array.
						wac = whitelist_entity.whitelist_api_connections.where("api_id = ?", ananke_api.id)[0]
						wac_ids.delete_if{|list_id| list_id == wac.id}
					end
				end

				if contact.standing < ananke_api.whitelist_standings
					whitelist_entity = Whitelist.where("name = ?", contact.contactName)[0]
					#If this contact is already on the whitelist
					if whitelist_entity.nil? == false
						connection_api_ids = whitelist_entity.apis.pluck("api_id")

						#connection_api_ids = []
						#whitelist_entity.apis.each do |api|
						#	connection_api_ids.push(api.id)
						#end

						#If this contact does not have a connection with this api
						if connection_api_ids.include?(ananke_api.id) == true
							#Destroy the connection between this API and the whitelist entity
							wac = whitelist_entity.whitelist_api_connections.where("api_id = ?", ananke_api.id)[0]
							wac.destroy!
							#Remove the wac's id from the wac_ids array.
							wac_ids.delete_if{|id| id == wac.id}
						end
					end
				end
			end

			WhitelistLog.create(entity_name: ananke_api.main_entity_name, source_share_user: ananke_api.share_user.id, source_type: 2, addition: true, entity_type: 5, date: Date.today, time: Time.now)
			#Generate a whitelist_log entry for this pull
		end
		#Delete any whitelist api connections (wacs) that remain.
		#This should result in the removal of api sourced whitelist entities that are no longer supported by any APIs.
		if wac_ids.empty? == false
			wac_ids.each do |wac|
				WhitelistApiConnection.where("id = ?", wac)[0].destroy
			end
		end
	end
end