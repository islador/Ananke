require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

#Testing with sidekiq inline! runs the code the minute it is called without enqueuing it.
#These tests still hits the EVE API, and for that is thus unstable. The web portion needs to be mocked.
describe ApiKeyInfoWorker do
	let!(:user) {FactoryGirl.create(:user)}
	#islador -corp API
	let!(:api) {FactoryGirl.create(:api, user: user, v_code: "UyO6KSsDydLrZX7MwU048rqRiHwAexvLmSQgtiUbN0rIrVaUuGUZYmGuW2PkMSg1", key_id: "3229801")}
	#tany - Character API
	let!(:api_character) {FactoryGirl.create(:api, user: user, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235")}
	#Tera - Account API
	let!(:api_account) {FactoryGirl.create(:api, user: user, v_code: "thHJr2qQrhLog2u3REUn6RZLk89QXJUJD4I0cJoI12vJ9BMbJ79sySG4oo4xWLSI", key_id: "2564689")}
	work = ApiKeyInfoWorker.new

	
	it "Should set the API's main entity to the corporation of the character if the API is a corp API" do
		work.perform(api.key_id, api.v_code)

		apiDB = Api.where("key_id = ?", api.key_id)[0]
		apiDB.main_entity.should match "Frontier Explorer's League"
	end

	it "Should populate an API's characters if it is a character API." do
		work.perform(api_character.key_id, api_character.v_code)

		apiDB = Api.where("key_id = ?", api_character.key_id)[0]
		apiDB.characters.empty?.should be_false
	end

	it "Should populate an API's characters if it is an account API." do
		work.perform(api_account.key_id, api_account.v_code)

		apiDB = Api.where("key_id = ?", api_account.key_id)[0]
		apiDB.characters.empty?.should be_false
	end

end