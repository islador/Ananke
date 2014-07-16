FactoryGirl.define do
	factory :user do
		ignore do
			sequence(:set_email) {|n| "user#{n}@example.com"}
		end

		email {set_email}
		password "12345678"
		password_confirmation "12345678"
		confirmed_at Time.now
		confirmation_sent_at Time.now-50
	end

	factory :share do
		ignore do
			set_owner_id 1
			after(:create) { |instance| instance.owner_id = FactoryGirl.create(:share_user, share_id: instance.id).user_id; instance.save! }
		end

		sequence(:name){|n| "Share #{n}"}
		owner_id {set_owner_id}
		active true
		user_limit 10
		grade 1
		join_link nil

		factory :trial_share do
			grade 1
			user_limit 10
		end

		factory :basic_share do
			grade 2
			user_limit 50
		end

		factory :advanced_share do
			grade 3
			user_limit 250
		end

		factory :super_share do
			grade 4
			user_limit 500
		end
	end

	factory :share_user do
		ignore do
			set_share_id {FactoryGirl.create(:basic_share).id}
			set_user_id {FactoryGirl.create(:user).id}
		end
		share_id {set_share_id}
		user_id {set_user_id}
		user_role 0
		sequence(:main_char_name) {|n| "Main Char #{n}"}
		approved true
	end

	factory :api do
		ccp_type 2
		ananke_type 2
		#Tany's character API
		sequence(:key_id) {|n| "3255235"}
		v_code "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x"
		#Modified to create cassettes for testing.
		#key_id "2638835"
		#v_code "HGo53iK9v7nPHJ1rTMsNYBiQ4JISjP1vR2rM44KNNj4wAcVtNIJnWaWmeWheFuSo"
		#second cassette API
		#key_id "2638832"
		#v_code "rFhvKwpQnuVkIj0BmB8vgyYssR760i7a1pcTxxr4TPIlEiTwj8xXMRyAWpQsJ6Zi"
		#accessmask represents all options ticked
		accessmask 268435455
		active nil
		main_entity_name "John"
		main false
		share_user

		factory :corp_api do
			#Islador's corp API
			key_id "3229801"
			v_code "UyO6KSsDydLrZX7MwU048rqRiHwAexvLmSQgtiUbN0rIrVaUuGUZYmGuW2PkMSg1"
			#accessmask represents all options ticked
			accessmask 67108863
			ccp_type 1
			ananke_type 1
			main_entity_name "Alaskan Fish"
			whitelist_standings 0
			black_list_standings 0
		end

		factory :corp_api_skip_determine_type do
			#Islador's corp API
			key_id "3229801"
			v_code "UyO6KSsDydLrZX7MwU048rqRiHwAexvLmSQgtiUbN0rIrVaUuGUZYmGuW2PkMSg1"
			#accessmask represents all options ticked
			accessmask 67108863
			ccp_type 1
			ananke_type 1
			main_entity_name "Alaskan Fish"
			whitelist_standings 0
			black_list_standings 0
			after(:build) { |api| api.class.skip_callback(:create, :after, :determine_type) }
		end

		factory :character_api_skip_determine_type do
			after(:build) { |api| api.class.skip_callback(:create, :after, :determine_type) }
		end
	end

	factory :character do
		ignore do
			set_share_id {FactoryGirl.create(:basic_share).id}
		end
		sequence(:name) {|n| "Character#{n}"}
		sequence(:ccp_character_id) {|n| n}
		sequence(:corporationName) {|n| "Corporation#{n}"}
		sequence(:ccp_corporation_id) {|n| n}
		sequence(:allianceName) {|n| "Alliance#{n}"}
		sequence(:ccp_alliance_id) {|n| n}
		sequence(:factionName) {|n| "Faction#{n}"}
		sequence(:ccp_faction_id) {|n| n}
		main false
		api
		share_id {set_share_id} #this is poorly stubbed as a share_id value should be inhereted from the API on creation.
	end

	factory :whitelist do
		sequence(:name) {|n| "Name#{n}"}
		standing 0
		entity_type 1 #1 alliance, 2 corp, 3 faction, 4 character
		source_type 1 #1 for api, 2 for manual
		source_share_user 1 #this is poorly stubbed
		share_id {FactoryGirl.create(:basic_share).id}
	end

	factory :whitelist_log do
		sequence(:entity_name) {|n| "Name#{n}"}
		source_share_user 1 #this is poorly stubbed
		source_type 1 #1 for api, 2 for manual
		addition true
		entity_type 1 #1 alliance, 2 corp, 3 faction, 4 character
		date Date.today
		time Time.new(2014)
		share_id {FactoryGirl.create(:basic_share).id}
	end

	factory :whitelist_api_connection do
		ignore do
			set_api_id {FactoryGirl.create(:api).id}
			set_whitelist_id {FactoryGirl.create(:whitelist).id}
			set_share_id {FactoryGirl.create(:basic_share).id}
		end
		
		api_id {set_api_id}
		whitelist_id {set_whitelist_id}
		share_id {set_share_id}
	end

	factory :black_list_entity do
		ignore do
			set_source_share_user_id 1
			after(:create) { |instance| instance.source_share_user_id = FactoryGirl.create(:share_user, share_id: instance.share_id).user_id; instance.save! }
		end
		sequence(:name) {|n| "Name#{n}"}
		standing 0
		entity_type 1 #1 alliance, 2 corp, 3 faction, 4 character
		source_type 1 #1 for api, 2 for manual
		source_share_user_id {set_source_share_user_id}
		share_id {FactoryGirl.create(:basic_share).id}
	end

	factory :black_list_entity_log do
		ignore do
			set_source_share_user_id 1
			after(:create) { |instance| instance.source_share_user_id = FactoryGirl.create(:share_user, share_id: instance.share_id).user_id; instance.save! }
		end

		sequence(:entity_name) {|n| "Name#{n}"}
		source_share_user_id {set_source_share_user_id}
		source_type 1 #1 for api, 2 for manual
		addition true
		entity_type 1 #1 alliance, 2 corp, 3 faction, 4 character
		date Date.today
		time Time.new(2014)
		share_id {FactoryGirl.create(:basic_share).id}
	end
end