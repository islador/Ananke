FactoryGirl.define do
	factory :user do
		ignore do
			sequence(set_email) {|n| "user#{n}@example.com"}
		end

		email {set_email}
		password "12345678"
		password_confirmation "12345678"
	end

	factory :api do
		entity 0
		sequence(:key_id) {|n| "#{n}234789"}
		v_code "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
		#Modified to create cassettes for testing.
		#key_id "2638835"
		#v_code "HGo53iK9v7nPHJ1rTMsNYBiQ4JISjP1vR2rM44KNNj4wAcVtNIJnWaWmeWheFuSo"
		#second cassette API
		#key_id "2638832"
		#v_code "rFhvKwpQnuVkIj0BmB8vgyYssR760i7a1pcTxxr4TPIlEiTwj8xXMRyAWpQsJ6Zi"
		#accessmask represents all options ticked
		accessmask 268435455
		active 1
		user

		factory :corp_api do
			#accessmask represents all options ticked
			accessmask 67108863
			entity 1
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
		sequence(:facitonID) {|n| n}
		api
	end
end