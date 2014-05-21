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
			set_owner_id {FactoryGirl.create(:user).id}
		end

		sequence(:name){|n| "Share #{n}"}
		owner_id {set_owner_id}
		active true
		user_limit 10
		grade 1

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
		active true
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
		end
	end

	factory :character do
		sequence(:name) {|n| "Character#{n}"}
		sequence(:characterID) {|n| n}
		sequence(:corporationName) {|n| "Corporation#{n}"}
		sequence(:corporationID) {|n| n}
		sequence(:allianceName) {|n| "Alliance#{n}"}
		sequence(:allianceID) {|n| n}
		sequence(:factionName) {|n| "Faction#{n}"}
		sequence(:factionID) {|n| n}
		main false
		api
	end

	factory :whitelist do
		sequence(:name) {|n| "Name#{n}"}
		standing 0
		entity_type 1 #1 alliance, 2 corp, 3 faction, 4 character
		source_type 1 #1 for api, 2 for manual
		source_user 1
	end

	factory :whitelist_log do
		sequence(:entity_name) {|n| "Name#{n}"}
		source_user 1
		source_type 1 #1 for api, 2 for manual
		addition true
		entity_type 1 #1 alliance, 2 corp, 3 faction, 4 character
		date Date.today
		time Time.new(2014)
	end

	factory :whitelist_api_connection do
		ignore do
			set_api_id {FactoryGirl.create(:api).id}
			set_whitelist_id {FactoryGirl.create(:whitelist).id}
		end
		
		api_id {set_api_id}
		whitelist_id {set_whitelist_id}
	end
end