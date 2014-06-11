require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe ApiCorpContactPullWorker do
	describe "Perform > " do
		let!(:user) {FactoryGirl.create(:user)}
		let!(:share) {FactoryGirl.create(:share)}
		let!(:share_user){FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}
		let!(:corp_api) {
			VCR.use_cassette('workers/api_key_info/corpAPI') do
				FactoryGirl.create(:corp_api, share_user: share_user, whitelist_standings: 5)
			end
		}
		let!(:whitelist_entity_api) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 10, name: "Alexander Fits", share_id: share.id)}
		let!(:whitelist_entity_manual) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, source_type: 2, standing: -10, name: "Jacob Dallen", share_id: share.id)}
		let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist_entity_api.id, share_id: share.id)}
		let!(:whitelist_api_standings_invalid) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 5, name: "Flapjack Shortpants", share_id: share.id)}
		let!(:whitelist_api_connection_standings_invalid) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: whitelist_api_standings_invalid.id, share_id: share.id)}

		#Second API, a whitelist entity, and two connections, one to corp_api and one to second_api
		let!(:second_api) {
			VCR.use_cassette('workers/api_key_info/corpAPI') do
				FactoryGirl.create(:corp_api, share_user: share_user, whitelist_standings: 10)
			end
		}
		let!(:second_whitelist_entity) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 5, name: "PlusFive", share_id: share.id)}
		let!(:second_whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: second_api.id, whitelist_id: second_whitelist_entity.id, share_id: share.id)}
		let!(:corp_whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: corp_api.id, whitelist_id: second_whitelist_entity.id, share_id: share.id)}

		work = ApiCorpContactPullWorker.new

		#This whole block is likely going to need to be duplicated in the whitelist controller and its spec.
		describe "Error Handling > " do
			let!(:inactive_api) {
				VCR.use_cassette('workers/api_key_info/corpAPI') do
					FactoryGirl.create(:corp_api, share_user: share_user, active: false)
				end
			}
			let!(:general_api) {
				VCR.use_cassette('workers/api_key_info/characterAPI') do
					FactoryGirl.create(:api, share_user: share_user)
				end
			}

			it "should throw an argument error if the API is not active." do
				expect{
					VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
						work.perform(inactive_api.id)
					end
				}.to raise_error ArgumentError
			end

			it "should throw an argument error if the API is not a corp API" do
				expect{
					VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
						work.perform(general_api.id)
					end
				}.to raise_error ArgumentError
			end
		end

		it "Should remove the triggering API's whitelist_api_connection from an entity that is no longer backed by this API but is still backed by another" do
			VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
				work.perform(second_api.id)
			end
			whitelistConnectionDB = WhitelistApiConnection.where("id = ?", second_whitelist_api_connection.id)[0]
			whitelistConnectionDB.should be_nil
		end

		it "Should remove existing entities that no longer match standings requirements." do
			VCR.use_cassette('workers/api_corp_contact/alliance_lowStandings') do
			#This spec tests for situations where the standings requirement has changed or the IG standing of the entity has changed
				work.perform(corp_api.id)
			end
				whitelistDB = Whitelist.where("name = 'Flapjack Shortpants'", )[0]
				whitelistDB.should be_nil
		end

		it "should add new entities to the whitelist that match standings requirements" do
			Whitelist.where("name = 'PlusSix' AND share_id = ?", share.id)[0].should be_nil
			Whitelist.where("name = 'PlusSeven' AND share_id = ?", share.id)[0].should be_nil
			Whitelist.where("name = 'PlusEight' AND share_id = ?", share.id)[0].should be_nil
			Whitelist.where("name = 'PlusNine' AND share_id = ?", share.id)[0].should be_nil
			Whitelist.where("name = 'PlusTen' AND share_id = ?", share.id)[0].should be_nil

			#Cassette requires one character of each standing, -10 through +10
			VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
				work.perform(corp_api.id)
			end
			
			Whitelist.where("name = 'PlusSix' AND share_id = ?", share.id)[0].should_not be_nil
			Whitelist.where("name = 'PlusSeven' AND share_id = ?", share.id)[0].should_not be_nil
			Whitelist.where("name = 'PlusEight' AND share_id = ?", share.id)[0].should_not be_nil
			Whitelist.where("name = 'PlusNine' AND share_id = ?", share.id)[0].should_not be_nil
			Whitelist.where("name = 'PlusTen' AND share_id = ?", share.id)[0].should_not be_nil
		end

		it "should correctly apply contact type IDs to whtitelist entities" do
			VCR.use_cassette('workers/api_corp_contact/alliance_contactTypeSpread') do
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

		it "should add the input API's alliance to the whitelist, but not its corporation" do
			Whitelist.where("name = 'Alliance' AND share_id = ?", share.id)[0].should be_nil
			Whitelist.where("name = 'Corporation' AND share_id = ?", share.id)[0].should be_nil
			VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
				work.perform(corp_api.id)
			end
			Whitelist.where("name = 'Alliance' AND share_id = ?", share.id)[0].should_not be_nil
			Whitelist.where("name = 'Alaskan Fish' AND share_id = ?", share.id)[0].should be_nil
		end

		it "should add the input API's corp to the whitelist if there is no alliance" do
			Whitelist.where("name = ? AND share_id = ?", corp_api.main_entity_name, share.id)[0].should be_nil
			Whitelist.where("name = 'Alliance' AND share_id = ?", share.id)[0].should be_nil
			VCR.use_cassette('workers/api_corp_contact/corporation_standingsSpread') do
				work.perform(corp_api.id)
			end
			Whitelist.where("name = ? AND share_id = ?", corp_api.main_entity_name, share.id)[0].should_not be_nil
			Whitelist.where("name = 'Alliance' AND share_id = ?", share.id)[0].should be_nil
		end

		it "should not add new entities to the whitelist that do not meet or exceed standings requirements" do
			VCR.use_cassette('workers/api_corp_contact/alliance_standingsSpread') do
				work.perform(corp_api.id)
			end
			Whitelist.where("name = ? AND share_id = ?", "NegTen", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegNine", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegEight", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegSeven", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegSix", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegFive", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegFour", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegThree", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegTwo", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "NegOne", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "Zero", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusOne", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusTwo", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusThree", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusFour", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusFour", share.id)[0].should be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusFive", share.id)[0].should_not be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusSix", share.id)[0].should_not be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusSeven", share.id)[0].should_not be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusEight", share.id)[0].should_not be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusNine", share.id)[0].should_not be_nil
			Whitelist.where("name = ? AND share_id = ?", "PlusTen", share.id)[0].should_not be_nil
		end

		it "should not remove manually added entities" do
			#Cassette contains a -10 standing 'Jacob Dallen'
			VCR.use_cassette('workers/api_corp_contact/alliance_manualWhitelist') do
				work.perform(corp_api.id)
			end
			whitelistDB = Whitelist.where("source_type = 2")
			whitelistDB.count.should be 1
		end

		it "should not remove entities that match or exceed standings requirements." do
			#Cassette contains a +10 standing 'Alexander Fits'
			VCR.use_cassette('workers/api_corp_contact/alliance_exceedStandings') do
				work.perform(corp_api.id)
			end
			whitelistDB = Whitelist.where("standing = ?", whitelist_entity_api.standing)
			whitelistDB.should include whitelist_entity_api
		end

		it "should generate a whitelist_log entry for itself" do
			#Can use any cassette since this test isn't dependant on the input.
			VCR.use_cassette('workers/api_corp_contact/alliance_exceedStandings') do
				work.perform(corp_api.id)
			end
			WhitelistLog.where('entity_name = ?', corp_api.main_entity_name).count.should be 1
		end
	end
end