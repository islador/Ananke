# == Schema Information
#
# Table name: apis
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  ccp_type         :integer
#  key_id           :string(255)
#  v_code           :string(255)
#  accessmask       :integer
#  active           :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  main_entity_name :string(255)
#  ananke_type      :integer
#  main             :boolean
#  name             :string(255)
#

require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe Api do
	let(:user) {FactoryGirl.create(:user, :email => "user@example.com")}
	let!(:api) {FactoryGirl.create(:api, user: user, main: true)}
	let!(:api_character) {FactoryGirl.create(:character, api: api, main: true)}

	subject {api}

	it {should respond_to(:ccp_type)}
	it {should respond_to(:ananke_type)}
	it {should respond_to(:key_id)}
	it {should respond_to(:v_code)}
	it {should respond_to(:accessmask)}
	it {should respond_to(:active)}
	it {should respond_to(:main_entity_name)}
	it {should respond_to(:main)}
	it {should respond_to(:characters)}

	it {should be_valid}

	describe "Associations > " do
		it "should belong to a user with email 'user@example.com'" do
			api.user.email.should match "user@example.com"
		end

		let!(:characterZeke) {FactoryGirl.create(:character, :api => api, :name => "Zeke")}
		let!(:characterJessica) {FactoryGirl.create(:character, :api => api, :name => "Jessica")}
		let!(:characterJeff) {FactoryGirl.create(:character, :api => api, :name => "Jeff")}

		it "should have a character named Zeke" do
			api.characters.should include(characterZeke)
		end

		it "should have a character named Jessica" do
			api.characters.should include(characterJessica)
		end

		it "should have a character named Jeff" do
			api.characters.should include(characterJeff)
		end

		describe "Corp API >" do
			let!(:corp_api) {FactoryGirl.create(:corp_api, user: user)}
			let!(:whitelist) {FactoryGirl.create(:whitelist)}
			let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist.id)}

			subject{corp_api}

			it {should respond_to(:whitelists)}

			it "corp_api.whitelists should yield whitelist" do
				corp_api.whitelists[0].id.should be whitelist.id
			end
		end
	end

	describe "Validations > " do
		#describe "should validate presence of entity" do
		#	before {api.entity = nil}
		#	it {should_not be_valid}
		#end

		describe "should validate presence of key_id" do
			before {api.key_id = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of v_code" do
			before {api.v_code = nil}
			it {should_not be_valid}
		end

		#describe "should validate presence of accessmask" do
		#	before {api.accessmask = nil}
		#	it {should_not be_valid}
		#end

		#describe "should validate presence of active" do
		#	before {api.active = nil}
		#	it {should_not be_valid}
		#end
	end

	describe "set_main_entity_name" do
		it {should respond_to(:set_main_entity_name)}

		let!(:corporation_api) {FactoryGirl.create(:corp_api, user: user, main: true)}
		let!(:corp_character) {FactoryGirl.create(:character, api: corporation_api, main: true)}

		let!(:general_api) {FactoryGirl.create(:api, user: user)}
		let!(:general_character) {FactoryGirl.create(:character, api: api)}

		it "should add the main character's name to a corporation API's main_entity_name" do
			corporation_api.set_main_entity_name()

			apiDB = Api.where("id = ?", corporation_api.id)[0]
			apiDB.main_entity_name.should match "#{corp_character.name} - Alaskan Fish"
		end

		it "should set the main character's name as the api's main entity name" do
			api.set_main_entity_name()

			apiDB = Api.where("id = ?", api.id)[0]
			apiDB.main_entity_name.should match "#{api_character.name}"
		end

		it "should not work on a non-main API" do
			expect{
				general_api.set_main_entity_name()}.to raise_error ArgumentError
		end
	end
end
