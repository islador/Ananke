# == Schema Information
#
# Table name: apis
#
#  id                   :integer          not null, primary key
#  share_user_id        :integer
#  ccp_type             :integer
#  key_id               :string(255)
#  v_code               :string(255)
#  accessmask           :integer
#  active               :boolean
#  created_at           :datetime
#  updated_at           :datetime
#  main_entity_name     :string(255)
#  ananke_type          :integer
#  main                 :boolean
#  name                 :string(255)
#  whitelist_standings  :integer
#  black_list_standings :integer
#

require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe Api do
	let(:user) {FactoryGirl.create(:user, :email => "user@example.com")}
	let(:share_user) {FactoryGirl.create(:share_user, user_id: user.id)}
	let!(:api) {
		FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, v_code: "thHJr2qQrhLog2u3REUn6RZLk89QXJUJD4I0cJoI12vJ9BMbJ79sySG4oo4xWLSI", key_id: "2564689", main: true)
	}
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
	it {should respond_to(:whitelist_standings)}
	it {should respond_to(:black_list_standings)}

	it {should be_valid}

	describe "Associations > " do
		it "should belong to a user with email 'user@example.com'" do
			api.share_user.user.email.should match "user@example.com"
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
			describe "whitelist_api_connections > " do
				let!(:corp_api) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
				let!(:whitelist) {FactoryGirl.create(:whitelist)}
				let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist.id)}

				subject{corp_api}

				it {should respond_to(:whitelists)}

				it "corp_api.whitelists should yield whitelist" do
					expect(corp_api.whitelists).to eq([whitelist])
				end

				it "should destroy its whitelist_api_connections when destroyed" do
					expect{corp_api.destroy}.to change(WhitelistApiConnection, :count).by(-1)
				end
			end

			describe "black_list_entity_api_connections > " do
				let!(:corp_api) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
				let!(:black_list_entity) {FactoryGirl.create(:black_list_entity)}
				let!(:black_list_entity_api_connection) {FactoryGirl.create(:black_list_entity_api_connection, api_id: corp_api.id, black_list_entity_id: black_list_entity.id)}

				subject {corp_api}

				it {should respond_to(:black_list_entities)}

				it "corp_api.black_list_entities should yield black_list_entities" do
					expect(corp_api.black_list_entities).to eq([black_list_entity])
				end

				it "should destroy its black_list_entity_api_connections when destroyed" do
					expect{corp_api.destroy}.to change(BlackListEntityApiConnection, :count).by(-1)
				end
			end
		end
	end

	describe "Callbacks > " do
		describe "after_save :inform_share_user > " do
			let(:share_user) {FactoryGirl.create(:share_user, user_id: user.id)}
			let!(:api) {
				FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, v_code: "thHJr2qQrhLog2u3REUn6RZLk89QXJUJD4I0cJoI12vJ9BMbJ79sySG4oo4xWLSI", key_id: "2564689", main: true)
			}

			it "should disapprove the share_user if the api is an inactive main api" do
				api.active = false
				api.save
				expect(ShareUser.find(share_user.id).approved).to be false
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
end
