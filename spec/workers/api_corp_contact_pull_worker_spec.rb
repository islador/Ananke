require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe ApiCorpContactPullWorker do
	describe "Perform > " do
		let!(:user) {FactoryGirl.create(:user)}
		#Add a whitelist standings column to the API
		let!(:corp_api) {FactoryGirl.create(:corp_api, user: user, whitelist_standings: 5, main_entity_name: "Frontier Explorer's League")}
		let!(:whitelist_entity_api) {FactoryGirl.create(:whitelist, source_user: user.id, standing: 10, name: "Alexander Fits")}
		let!(:whitelist_entity_manual) {FactoryGirl.create(:whitelist, source_user: user.id, source_type: 2, standing: -10, name: "Jacob Dallen")}
		let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist_entity_api.id)}
		let!(:whitelist_api_standings_invalid) {FactoryGirl.create(:whitelist, source_user: user.id, standing: 5, name: "Flapjack Shortpants")}
		let!(:whitelist_api_connection_standings_invalid) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist_api_standings_invalid.id)}

		#Second API, a whitelist entity, and two connections, one to corp_api and one to second_api
		let!(:second_api) {FactoryGirl.create(:corp_api, user: user, whitelist_standings: 10, main_entity_name: "Frontier Explorer's League")}
		let!(:second_whitelist_entity) {FactoryGirl.create(:whitelist, source_user: user.id, standing: 5, name: "PlusFive")}
		let!(:second_whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: second_api.id, whitelist_id: second_whitelist_entity.id)}
		let!(:corp_whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: second_whitelist_entity.id)}

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

		it "Should remove the triggering API's whitelist_api_connection from an entity that is no longer backed by this API but is still backed by another" do
			#Tests that only a whitelist_api_connection is removed if an entity has multiple supporting APIs
			VCR.use_cassette('workers/corpContactList_standingsSpread') do
				work.perform(second_api.id)
			end
			whitelistDB = Whitelist.where("name = ?", 'PlusFive')[0]
			whitelistDB.should_not be_nil
			whitelistDB.apis.should_not include second_api
		end

		it "Should remove existing entities that no longer match standings requirements." do
			VCR.use_cassette('workers/corpContactList_lowStandings') do
			#This spec tests for situations where the standings requirement has changed or the IG standing of the entity has changed
				work.perform(corp_api.id)
			end
				whitelistDB = Whitelist.where("name = 'Flapjack Shortpants'", )[0]
				whitelistDB.should be_nil
		end

		it "should add new entities to the whitelist that match standings requirements" do
			count = Whitelist.where("source_type = 1").count
			#Cassette requires one character of each standing, -10 through +10
			VCR.use_cassette('workers/corpContactList_standingsSpread') do
				work.perform(corp_api.id)
			end
			whitelistDB = Whitelist.where("source_type = 1")
			(whitelistDB.count - count).should be 5
		end

		it "should correctly apply contact type IDs to whtielist entities" do
			VCR.use_cassette('workers/corpContactList_contactTypeSpread') do
				work.perform(corp_api.id)
			end
			characterType = Whitelist.where("name = ?", "CharacterType")[0].entity_type
			characterType.should be 4

			corporationType = Whitelist.where("name = ?", "CorporationType")[0].entity_type
			corporationType.should be 2

			factionType = Whitelist.where("name = ?", "FactionType")[0].entity_type
			factionType.should be 3
			
			allianceType = Whitelist.where("name = ?", "AllianceType")[0].entity_type
			allianceType.should be 1
		end
		
		it "should not add new entities to the whitelist that do not meet or exceed standings requirements" do
			VCR.use_cassette('workers/corpContactList_standingsSpread') do
				work.perform(corp_api.id)
			end
			Whitelist.where("name = ?", "NegTen")[0].should be_nil
			Whitelist.where("name = ?", "NegNine")[0].should be_nil
			Whitelist.where("name = ?", "NegEight")[0].should be_nil
			Whitelist.where("name = ?", "NegSeven")[0].should be_nil
			Whitelist.where("name = ?", "NegSix")[0].should be_nil
			Whitelist.where("name = ?", "NegFive")[0].should be_nil
			Whitelist.where("name = ?", "NegFour")[0].should be_nil
			Whitelist.where("name = ?", "NegThree")[0].should be_nil
			Whitelist.where("name = ?", "NegTwo")[0].should be_nil
			Whitelist.where("name = ?", "NegOne")[0].should be_nil
			Whitelist.where("name = ?", "Zero")[0].should be_nil
			Whitelist.where("name = ?", "PlusOne")[0].should be_nil
			Whitelist.where("name = ?", "PlusTwo")[0].should be_nil
			Whitelist.where("name = ?", "PlusThree")[0].should be_nil
			Whitelist.where("name = ?", "PlusFour")[0].should be_nil
		end

		it "should not remove manually added entities" do
			#Cassette contains a -10 standing 'Jacob Dallen'
			VCR.use_cassette('workers/corpContactList_manualWhitelist') do
				work.perform(corp_api.id)
			end
			whitelistDB = Whitelist.where("source_type = 2")
			whitelistDB.count.should be 1
		end

		it "should not remove entities that match or exceed standings requirements." do
			#Cassette contains a +10 standing 'Alexander Fits'
			VCR.use_cassette('workers/corpContactList_exceedStandings') do
				work.perform(corp_api.id)
			end
			whitelistDB = Whitelist.where("standing = ?", whitelist_entity_api.standing)
			whitelistDB.should include whitelist_entity_api
		end

		it "should generate a whitelist_log entry for itself" do
			#Can use any cassette since this test isn't dependant on the input.
			VCR.use_cassette('workers/corpContactList_exceedStandings') do
				work.perform(corp_api.id)
			end
			#WhitelistLog.last.entity_name.should match corp_api.main_entity_name
			WhitelistLog.where('entity_name = ?', corp_api.main_entity_name).count.should be 1
		end
	end
end