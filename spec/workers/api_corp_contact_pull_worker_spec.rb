require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe ApiCorpContactPullWorker do
	describe "Perform > " do
		let!(:user) {FactoryGirl.create(:user)}
		#Add a whitelist standings column to the API
		let!(:corp_api) {FactoryGirl.create(:corp_api, user: user, whitelist_standings: 10, main_entity_name: "Frontier Explorer's League")}
		let!(:whitelist_entity_api) {FactoryGirl.create(:whitelist, source_user: user.id, standing: 10)}
		let!(:whitelist_entity_manual) {FactoryGirl.create(:whitelist, source_user: user.id, source_type: 2)}
		let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist_entity_api.id)}
		let!(:whitelist_api_standings_invalid) {FactoryGirl.create(:whitelist, source_user: user.id, standing: 5, name: "Flapjack Shortpants")}
		let!(:whitelist_api_connection_standings_invalid) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist_api_standings_invalid.id)}
		work = ApiCorpContactPullWorker.new

		#This whole block is likely going to need to be duplicated in the whitelist controller and its spec.
		describe "Error Handling > " do
			let!(:inactive_api) {FactoryGirl.create(:corp_api, user: user, active: false)}
			let!(:general_api) {FactoryGirl.create(:api, user: user)}
			it "should throw an argument error if the API is not active." do
				expect{
					work.perform(inactive_api.id)
				}.to raise_error ArgumentError
			end

			it "should throw an argument error if the API is not a corp API" do
				expect{
					work.perform(general_api.id)
				}.to raise_error ArgumentError
			end
		end

		#I don't believe it is possible to test this
		xit "Should query the corp contact list on the eve API" do
		end

		#I don't believe it is possible to test this
		xit "Should check for any existing entities in the database belonging to the API" do
			work.perform(corp_api.id)
			expect(assigns(:entities).count).to be 1
		end

		#Possibly need a 'whitelist standings' column on the api model for this.
		it "Should remove existing entities that no longer match standings requirements." do
			#This spec tests for situations where the standings requirement has changed or the IG standing of the entity has changed
			work.perform(corp_api.id)
			whitelistDB = Whitelist.where("standing = ?", whitelist_api_standings_invalid.standing)[0]
			whitelistDB.should be_nil
		end

		#This spec requires stubbing input data. That needs to be done, but is a separate project.
		xit "should add new entities to the whitelist that match standings requirements" do
		end

		#This spec requires stubbing input data. That needs to be done, but is a separate project.
		xit "should not add new entities to the whitelist that do not meet or exceed standings requirements" do
		end

		it "should not remove manually added entities" do
			work.perform(corp_api.id)
			whitelistDB = Whitelist.where("source_type = 2")
			whitelistDB.count.should be 1
		end

		it "should not remove entities that match or exceed standings requirements." do
			work.perform(corp_api.id)
			whitelistDB = Whitelist.where("standing = ?", whitelist_entity_api.standing)
			whitelistDB.should include whitelist_entity_api
		end

		it "should generate a whitelist_log entry for itself" do
			work.perform(corp_api.id)
			#WhitelistLog.last.entity_name.should match corp_api.main_entity_name
			WhitelistLog.where('entity_name = ?', corp_api.main_entity_name).count.should be 1
		end
	end
end