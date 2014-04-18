require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

#Testing with sidekiq inline! runs the code the minute it is called without enqueuing it.
describe ApiKeyInfoWorker do
	let!(:user) {FactoryGirl.create(:user)}
	#islador -corp API
	let!(:api) {
		VCR.use_cassette('workers/api_key_info/corpAPI') do
			FactoryGirl.create(:api, user: user, v_code: "UyO6KSsDydLrZX7MwU048rqRiHwAexvLmSQgtiUbN0rIrVaUuGUZYmGuW2PkMSg1", key_id: "3229801")
		end
	}
	#tany - Character API
	let!(:api_character) {
		VCR.use_cassette('workers/api_key_info/characterAPI') do
			FactoryGirl.create(:api, user: user, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235")
		end
	}
	#Tera - Account API
	let!(:api_account) {
		VCR.use_cassette('workers/api_key_info/accountAPI') do
			FactoryGirl.create(:api, user: user, v_code: "thHJr2qQrhLog2u3REUn6RZLk89QXJUJD4I0cJoI12vJ9BMbJ79sySG4oo4xWLSI", key_id: "2564689")
		end
	}
	work = ApiKeyInfoWorker.new

	
	it "Should set the API's main entity name to the corporation of the character if the API is a corp API" do
		VCR.use_cassette('workers/api_key_info/corpAPI') do
			work.perform(api.key_id, api.v_code)
		end
		
		apiDB = Api.where("key_id = ?", api.key_id)[0]
		apiDB.main_entity_name.should match "Alaskan Fish"
	end

	it "Should set the API's ananke_type to 'corporation' if the api is a corporation type api" do
		VCR.use_cassette('workers/api_key_info/corpAPI') do
			work.perform(api.key_id, api.v_code)
		end

		apiDB = Api.where("key_id = ?", api.key_id)[0]
		apiDB.ananke_type.should be 1
	end

	it "Should set the API's ananke_type to 'general' if the api is an account type api" do
		VCR.use_cassette('workers/api_key_info/characterAPI') do
			work.perform(api_character.key_id, api_character.v_code)
		end

		apiDB = Api.where("key_id = ?", api_character.key_id)[0]
		apiDB.ananke_type.should be 2
	end

	it "Should set the API's ananke_type to 'general' if the api is a character type api" do
		VCR.use_cassette('workers/api_key_info/accountAPI') do
			work.perform(api_account.key_id, api_account.v_code)
		end
		
		apiDB = Api.where("key_id = ?", api_account.key_id)[0]
		apiDB.ananke_type.should be 2
	end

	it "Should populate an API's characters if it is a character API." do
		VCR.use_cassette('workers/api_key_info/characterAPI') do
			work.perform(api_character.key_id, api_character.v_code)
		end

		apiDB = Api.where("key_id = ?", api_character.key_id)[0]
		apiDB.characters.empty?.should be_false
	end

	it "Should populate an API's characters if it is an account API." do
		VCR.use_cassette('workers/api_key_info/accountAPI') do
			work.perform(api_account.key_id, api_account.v_code)
		end

		apiDB = Api.where("key_id = ?", api_account.key_id)[0]
		apiDB.characters.empty?.should be_false
	end

end