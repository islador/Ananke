require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

#Testing with sidekiq inline! runs the code the minute it is called without enqueuing it.
describe WhitelistUpdateWorker do
	describe "Perform > " do
		let(:user) {FactoryGirl.create(:user)}
		let(:share) {FactoryGirl.create(:basic_share)}
		let!(:share_user){FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}

		work = WhitelistUpdateWorker.new

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
			let!(:error_handling_whitelist) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 5, name: "PlusFive", share_id: share.id)}
			let!(:wac_non_corp_api) {FactoryGirl.create(:whitelist_api_connection, api_id: general_api.id, whitelist_id: error_handling_whitelist.id, share_id: share.id)}
			let!(:wac_inactive_corp_api) {FactoryGirl.create(:whitelist_api_connection, api_id: inactive_api.id, whitelist_id: error_handling_whitelist.id, share_id: share.id)}

			it "should throw an argument error if the API is not active." do
				expect{
					VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
						work.perform(share.id)
					end
				}.to raise_error ArgumentError
			end

			it "should throw an argument error if the API is not a corp API" do
				expect{
					VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
						work.perform(share.id)
					end
				}.to raise_error ArgumentError
			end
		end

		describe "With a single standings 5 API" do
			#Test Prep
			let!(:standings_5_corp_api) {
				VCR.use_cassette('workers/api_key_info/corpAPI') do
					FactoryGirl.create(:corp_api, share_user: share_user, whitelist_standings: 5)
				end
			}
			let(:plus4_whitelist_entity) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 4, name: "PlusFour", share_id: share.id)}
			let!(:plus4_standings5_wac) {FactoryGirl.create(:whitelist_api_connection, api_id: standings_5_corp_api.id, whitelist_id: plus4_whitelist_entity.id, share_id: share.id)}

			let(:plus5_whitelist_entity) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 5, name: "PlusFive", share_id: share.id)}
			let!(:plus5_standings5_wac) {FactoryGirl.create(:whitelist_api_connection, api_id: standings_5_corp_api.id, whitelist_id: plus5_whitelist_entity.id, share_id: share.id)}

			let(:plus10_whitelist_entity) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 10, name: "PlusTen", share_id: share.id)}
			let!(:plus10_standings5_wac) {FactoryGirl.create(:whitelist_api_connection, api_id: standings_5_corp_api.id, whitelist_id: plus10_whitelist_entity.id, share_id: share.id)}

			let!(:manually_added_whitelist_entity) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, source_type: 2, standing: -10, name: "Jacob Dallen", share_id: share.id)}

			#Specs
			it "Should remove existing entities that are returned by the API but no longer match standings requirements." do
				#Ensure plus4 is in the DB before running the worker.
				WhitelistApiConnection.where("id = ?", plus4_standings5_wac.id)[0].should_not be_nil
				Whitelist.where("name = ? AND share_id = ?", plus4_whitelist_entity.name, share.id)[0].should_not be_nil
				
				VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
				#This spec tests for situations where the standings requirement has changed or the IG standing of the entity has changed
					work.perform(share.id)
				end
				#Check that plus4 is no longer in the DB
				WhitelistApiConnection.where("id = ?", plus4_standings5_wac.id)[0].should be_nil
				Whitelist.where("name = ? AND share_id = ?", plus4_whitelist_entity.name, share.id)[0].should be_nil
			end

			it "should remove existing entities that are no longer returned by the API query" do
				WhitelistApiConnection.where("id = ?", plus4_standings5_wac.id)[0].should_not be_nil
				Whitelist.where("id = ?", plus4_whitelist_entity.id)[0].should_not be_nil
				WhitelistApiConnection.where("id = ?", plus5_standings5_wac.id)[0].should_not be_nil
				Whitelist.where("id = ?", plus5_whitelist_entity.id)[0].should_not be_nil
				WhitelistApiConnection.where("id = ?", plus10_standings5_wac.id)[0].should_not be_nil
				Whitelist.where("id = ?", plus10_whitelist_entity.id)[0].should_not be_nil

				VCR.use_cassette('workers/corpContactList_emptyReturn', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				WhitelistApiConnection.where("id = ?", plus4_standings5_wac.id)[0].should be_nil
				Whitelist.where("id = ?", plus4_whitelist_entity.id)[0].should be_nil
				WhitelistApiConnection.where("id = ?", plus5_standings5_wac.id)[0].should be_nil
				Whitelist.where("id = ?", plus5_whitelist_entity.id)[0].should be_nil
				WhitelistApiConnection.where("id = ?", plus10_standings5_wac.id)[0].should be_nil
				Whitelist.where("id = ?", plus10_whitelist_entity.id)[0].should be_nil
			end

			it "should remove existing entity's WACs that are no longer returned by the API query" do
				VCR.use_cassette('workers/whitelist_update_worker/corpContactList_standingsSpreadMinusPlus5') do
					work.perform(share.id)
				end
				WhitelistApiConnection.where("id = ?", plus5_standings5_wac.id)[0].should be_nil
				Whitelist.where("id = ?", plus5_whitelist_entity.id)[0].should be_nil
			end

			it "should add new entities to the whitelist that match standings requirements" do
				VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
					work.perform(share.id)
				end

				#Check for records that match the standings profile, but were not created during test prep.
				Whitelist.where("name = 'PlusSix' AND share_id = ?", share.id)[0].should_not be_nil
				Whitelist.where("name = 'PlusSeven' AND share_id = ?", share.id)[0].should_not be_nil
				Whitelist.where("name = 'PlusEight' AND share_id = ?", share.id)[0].should_not be_nil
				Whitelist.where("name = 'PlusNine' AND share_id = ?", share.id)[0].should_not be_nil
			end

			it "should correctly apply contact type IDs to whitelist entities" do
				VCR.use_cassette('workers/corpContactList_contactTypeSpread', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				characterType = Whitelist.where("name = ? AND share_id = ?", "CharacterType", share.id)[0].entity_type
				characterType.should be 4

				corporationType = Whitelist.where("name = ? AND share_id = ?", "CorporationType", share.id)[0].entity_type
				corporationType.should be 2

				factionType = Whitelist.where("name = ? AND share_id = ?", "FactionType", share.id)[0].entity_type
				factionType.should be 3
				
				allianceType = Whitelist.where("name = ? AND share_id = ?", "AllianceType", share.id)[0].entity_type
				allianceType.should be 1
			end

			it "should not add new entities to the whitelist that do not meet or exceed standings requirements" do
				VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
					work.perform(share.id)
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
				Whitelist.where("id = ?", manually_added_whitelist_entity.id).should_not be_nil
				#Cassette contains a -10 standing 'Jacob Dallen'
				VCR.use_cassette('workers/corpContactList_manualWhitelist', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				Whitelist.where("id = ?", manually_added_whitelist_entity.id).should_not be_nil
			end

			it "should not remove entities or their WACs that match or exceed standings requirements." do
				#Cassette contains a +10 standing 'Alexander Fits'
				Whitelist.where("name = ? AND share_id = ?", plus10_whitelist_entity.name, share.id)[0].should_not be_nil
				Whitelist.where("name = ? AND share_id = ?", plus10_whitelist_entity.name, share.id)[0].whitelist_api_connections[0].should_not be_nil

				VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				whitelistDB = Whitelist.where("standing = ?", plus10_whitelist_entity.standing)
				whitelistDB.should include plus10_whitelist_entity

				wac = Whitelist.where("name = ? AND share_id = ?", plus10_whitelist_entity.name, share.id)[0].whitelist_api_connections[0]
				wac.should_not be_nil
				wac.should eq(plus10_standings5_wac)
			end

			it "should generate a whitelist_log entry for itself" do
				#Can use any cassette since this test isn't dependant on the input.
				VCR.use_cassette('workers/corpContactList_exceedStandings', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				WhitelistLog.where('entity_name = ? AND share_id = ?', standings_5_corp_api.main_entity_name, share.id).count.should be 1
			end
		end
	end
end