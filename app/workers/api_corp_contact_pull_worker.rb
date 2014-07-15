class ApiCorpContactPullWorker
	include Sidekiq::Worker

	def perform(api_id)
		#Retrieve the API from the database
		ananke_api = Api.where("id = ?", api_id)[0]

		raise ArgumentError, "Api must be a corporation API." if ananke_api.ananke_type != 1
		raise ArgumentError, "Api must be active." if ananke_api.active != true

		#Construct an eve api with the eve gem
		eve_api = Eve::API.new(:key_id => ananke_api.key_id, :v_code => ananke_api.v_code)

		#Query the API for host character info
		result = eve_api.account.apikeyinfo
		corp_name = ""
		alliance_name = ""
		#Create a whitelist entity for the api's alliance if possible
		if result.key.characters[0].allianceName != false
			alliance_name = result.key.characters[0].allianceName
			whitelist_entity = Whitelist.where("name = ? AND share_id = ?", alliance_name, ananke_api.share_user.share_id)[0]
			#If there is not currently a whitelist entity for the alliance, save the API's alliance to the whitelist and build out a wac connecting it and the ananke_api
			if whitelist_entity.nil? == true
				new_entity = Whitelist.create(name: alliance_name, entity_type: 1, source_type: 1, source_share_user: ananke_api.share_user.id, standing: 10, share_id: ananke_api.share_user.share_id)
				wac = ananke_api.whitelist_api_connections.build(whitelist_id: new_entity.id, share_id: ananke_api.share_user.share_id)
				if wac.invalid? == true
					raise wac.errors.messages
				else
					wac.save!
				end
			else
				#if there is a current whitelist entity for the alliance, update it and build out a wac connecting it and the ananke_api.
				whitelist_entity.standing = 10
				whitelist_entity.source_type = 1
				whitelist_entity.save!

				wac = ananke_api.whitelist_api_connections.build(whitelist_id: whitelist_entity.id, share_id: ananke_api.share_user.share_id)
				if wac.invalid? == true
					raise wac.errors.messages
				else
					wac.save!
				end
			end
		else
			#Otherwise, create a whitelist entity for the API's corporation
			corp_name = result.key.characters[0].corporationName
			whitelist_entity = Whitelist.where("name = ? AND share_id = ?", corp_name, ananke_api.share_user.share_id)[0]
			#If there is not currently a whitelist entity for the alliance, save the API's alliance to the whitelist and build out a wac connecting it and the ananke_api
			if whitelist_entity.nil? == true
				new_entity = Whitelist.create(name: corp_name, entity_type: 2, source_type: 1, source_share_user: ananke_api.share_user.id, standing: 10, share_id: ananke_api.share_user.share_id)
				wac = ananke_api.whitelist_api_connections.build(whitelist_id: new_entity.id, share_id: ananke_api.share_user.share_id)
				if wac.invalid? == true
					raise wac.errors.messages
				else
					wac.save!
				end
			else
				#if there is a current whitelist entity for the corporation, update it and build out a wac connecting it and the ananke_api.
				whitelist_entity.standing = 10
				whitelist_entity.source_type = 1
				whitelist_entity.save!

				wac = ananke_api.whitelist_api_connections.build(whitelist_id: whitelist_entity.id, share_id: ananke_api.share_user.share_id)
				if wac.invalid? == true
					raise wac.errors.messages
				else
					wac.save!
				end
			end
		end

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
				whitelist_entity = Whitelist.where("name = ? AND share_id = ?", contact.contactName, ananke_api.share_user.share_id)[0]
				#If this contact does not exist on the whitelist.  
				if whitelist_entity.nil? == true
					#Create a whitelist entity from it
					new_entity = Whitelist.create(name: contact.contactName, entity_type: contact_type, source_type: 1, source_share_user: ananke_api.share_user.id, standing: contact.standing, share_id: ananke_api.share_user.share_id)

					#and create a connection between that entity and the source API
					wac = ananke_api.whitelist_api_connections.build(whitelist_id: new_entity.id, share_id: ananke_api.share_user.share_id)
					if wac.invalid? == true
						raise wac.errors.messages
					else
						wac.save!
					end
				end
			end

			if contact.standing < ananke_api.whitelist_standings
				whitelist_entity = Whitelist.where("name = ? AND share_id = ?", contact.contactName, ananke_api.share_user.share_id)[0]
				#If this contact is already on the whitelist
				if whitelist_entity.nil? == false
					connection_api_ids = []
					whitelist_entity.apis.each do |api|
						connection_api_ids.push(api.id)
					end
					#If this contact does not have a connection with this api
					if connection_api_ids.include?(ananke_api.id) == false
						#Do nothing
					#If this contact has a whitelist_api_connection with this api
					else
						#Destroy the connection between this API and the whitelist entity
						whitelist_entity.whitelist_api_connections.where("api_id = ?", ananke_api.id)[0].destroy
					end
				end
			end
		end

		WhitelistLog.create(entity_name: ananke_api.main_entity_name, source_share_user: ananke_api.share_user.id, source_type: 2, addition: true, entity_type: 5, date: Date.today, time: Time.now, share_id: ananke_api.share_user.share_id)
		#Generate a whitelist_log entry for this pull

	end
end