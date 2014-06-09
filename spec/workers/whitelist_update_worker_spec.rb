require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

#Testing with sidekiq inline! runs the code the minute it is called without enqueuing it.
describe WhitelistUpdateWorker do
	describe "Perform > " do
		let(:user) {FactoryGirl.create(:user)}
		let(:share) {FactoryGirl.create(:basic_share)}
		let!(:share_user){FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}

		let!(:standings_5_corp_api) {
			VCR.use_cassette('workers/api_key_info/corpAPI') do
				FactoryGirl.create(:corp_api, share_user: share_user, whitelist_standings: 5)
			end
		}
		#Second API, a whitelist entity, and two connections, one to corp_api and one to second_api
		let!(:standings_10_corp_api) {
			VCR.use_cassette('workers/api_key_info/corpAPI') do
				FactoryGirl.create(:corp_api, share_user: share_user, whitelist_standings: 10)
			end
		}

		work = WhitelistUpdateWorker.new

		describe "Error Handling > " do
			let(:inactive_api) {
				VCR.use_cassette('workers/api_key_info/corpAPI') do
					FactoryGirl.create(:corp_api, share_user: share_user, active: false)
				end
			}
			let(:general_api) {
				VCR.use_cassette('workers/api_key_info/characterAPI') do
					FactoryGirl.create(:api, share_user: share_user)
				end
			}
			let(:error_handling_whitelist) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 5, name: "PlusFive", share_id: share.id)}
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

		let!(:plus5_whitelist_entity) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 5, name: "PlusFive", share_id: share.id)}
		let!(:plus5_standings10_wac) {FactoryGirl.create(:whitelist_api_connection, api_id: standings_10_corp_api.id, whitelist_id: plus5_whitelist_entity.id, share_id: share.id)}
		let!(:plus5_standings5_wac) {FactoryGirl.create(:whitelist_api_connection, api_id: standings_5_corp_api.id, whitelist_id: plus5_whitelist_entity.id, share_id: share.id)}

		let!(:plus10_whitelist_entity) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, standing: 10, name: "PlusTen", share_id: share.id)}
		let!(:plus10_standings10_wac) {FactoryGirl.create(:whitelist_api_connection, api_id: standings_10_corp_api.id, whitelist_id: plus10_whitelist_entity.id, share_id: share.id)}
		let!(:plus10_standings5_wac) {FactoryGirl.create(:whitelist_api_connection, api_id: standings_5_corp_api.id, whitelist_id: plus10_whitelist_entity.id, share_id: share.id)}

		it "Should remove the triggering API's whitelist_api_connection from an entity that is no longer backed by this API but is still backed by another" do
			WhitelistApiConnection.where("id = ?", plus5_standings10_wac.id)[0].should_not be_nil
			VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			WhitelistApiConnection.where("id = ?", plus5_standings10_wac.id)[0].should be_nil
			Whitelist.where("id = ?", plus5_whitelist_entity.id)[0].should_not be_nil
		end

		it "Should remove existing entities that no longer match standings requirements." do
			VCR.use_cassette('workers/corpContactList_lowStandings', :allow_playback_repeats => true) do
			#This spec tests for situations where the standings requirement has changed or the IG standing of the entity has changed
				work.perform(share.id)
			end
				#whitelistDB = 
				Whitelist.where("name = 'Flapjack Shortpants'", )[0].should be_nil
				#whitelistDB.should be_nil
		end

		it "should add new entities to the whitelist that match standings requirements" do
			count = Whitelist.where("source_type = 1").count
			#Cassette requires one character of each standing, -10 through +10
			VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			whitelistDB = Whitelist.where("source_type = 1")
			(whitelistDB.count - count).should be 5
		end

		it "should correctly apply contact type IDs to whitelist entities" do
			VCR.use_cassette('workers/corpContactList_contactTypeSpread', :allow_playback_repeats => true) do
				work.perform(share.id)
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
			VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
				work.perform(share.id)
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
			VCR.use_cassette('workers/corpContactList_manualWhitelist', :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			whitelistDB = Whitelist.where("source_type = 2")
			whitelistDB.count.should be 1
		end

		it "should not remove entities that match or exceed standings requirements." do
			#Cassette contains a +10 standing 'Alexander Fits'
			VCR.use_cassette('workers/corpContactList_exceedStandings', :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			whitelistDB = Whitelist.where("standing = ?", plus10_whitelist_entity.standing)
			whitelistDB.should include plus10_whitelist_entity
		end

		it "should generate a whitelist_log entry for itself" do
			#Can use any cassette since this test isn't dependant on the input.
			VCR.use_cassette('workers/corpContactList_exceedStandings', :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			WhitelistLog.where('entity_name = ?', standings_5_corp_api.main_entity_name).count.should be 1
		end

		it "should remove entities that were created by an API, but are no longer supported by it" do
			VCR.use_cassette('workers/corpContactList_standingsSpread', :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			Whitelist.where("id = ?", plus5_whitelist_entity.id)[0].should be_nil
		end
	end
end