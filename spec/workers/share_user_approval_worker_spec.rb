require 'spec_helper'

describe ShareUserApprovalWorker do
	describe "Perform > " do
		let!(:user) {FactoryGirl.create(:user)}
		let!(:share) {FactoryGirl.create(:share)}
		let!(:share_user){FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id, approved: false)}
		let!(:api){FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, active: true, main: true)}
		let!(:main_character){FactoryGirl.create(:character, main:true, ccp_character_id: 2202, api: api)}

		let!(:approved_share_user){FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id, approved: true)}
		let!(:approved_api){FactoryGirl.create(:character_api_skip_determine_type, share_user: approved_share_user, active: true, main: true)}
		let!(:approved_main_character){FactoryGirl.create(:character, main:true, ccp_character_id: 9765, allianceName: "Alliance", api: approved_api)}
		let!(:off_character){FactoryGirl.create(:character, main:false, ccp_character_id: 567890, api: approved_api)}
		
		let!(:alliance_whitelist) {FactoryGirl.create(:whitelist, share_id: share.id, name: "Alliance")}
		let!(:corp_whitelist) {FactoryGirl.create(:whitelist, share_id: share.id, name: "Corporation", entity_type: 2)}
		let!(:faction_whitelist) {FactoryGirl.create(:whitelist, share_id: share.id, name: "Faction", entity_type: 3)}
		let!(:character_whitelist) {FactoryGirl.create(:whitelist, share_id: share.id, name: "Character", entity_type: 4)}

		work = ShareUserApprovalWorker.new

		it "should update the API's character affiliations" do
			#Code should use characterID to determine character's
			VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "VCRCharacter", :charID => 2202, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}, :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			char = Character.find(main_character.id)
			expect(char.name).to match "VCRCharacter"
			expect(char.ccp_corporation_id).to be 12345
			expect(char.corporationName).to match "VCRCorp"
			expect(char.ccp_alliance_id).to be 54321
			expect(char.allianceName).to match "VCRAlliance"
			expect(char.ccp_faction_id).to be 98765
			expect(char.factionName).to match "VCRFaction"
		end

		it "should create a new character for the API if one does not already exist" do
			VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "VCRCharacter", :charID => 567890, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}, :allow_playback_repeats => true) do
				work.perform(share.id)
			end
			expect(Character.where("ccp_character_id = ?", 567890)[0]).to_not be_nil
		end

		describe "Approvals > " do
			it "should approve a share_user if it's main character is a member of a whitelisted alliance" do
				VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "VCRCharacter", :charID => 2202, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "Alliance", :factionID=>98765, :factionName=>"VCRFaction"}, :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(ShareUser.find(share_user).approved).to be true
			end

			it "should approve a share user if it's main character is a member of a whitelisted corporation" do
				VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "VCRCharacter", :charID => 2202, :corpID => 12345, :corpName => "Corporation", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}, :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(ShareUser.find(share_user.id).approved).to be true
			end

			it "should approve a share user if it's main character is a member of a whitelisted faction" do
				VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "VCRCharacter", :charID => 2202, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"Faction"}, :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(ShareUser.find(share_user.id).approved).to be true
			end

			it "should approve a share user if it's main character is a whitelisted character" do
				VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "Character", :charID => 2202, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}, :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(ShareUser.find(share_user.id).approved).to be true
			end
		end

		describe "Disapprovals > " do
			it "should disapprove a share user if it's main character is no longer a whitelisted entity or a member of one" do
				VCR.use_cassette('workers/api_key_info/dynamicCharacterAPI', erb: {:charName => "VCRCharacter", :charID => 9765, :corpID => 12345, :corpName => "VCRCorp", :allianceID => 54321, :allianceName => "VCRAlliance", :factionID=>98765, :factionName=>"VCRFaction"}, :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(ShareUser.find(approved_share_user.id).approved).to be false
			end
		end

		describe "Expired/Auth Errors > " do
			it "should mark expired APIs as inactive" do
				VCR.use_cassette('workers/api_key_info/auth_errors/expired_accountAPI', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(Api.find(approved_api.id).active).to be false
			end

			it "should disapprove share_user's with main APIs that return expired errors" do
				VCR.use_cassette('workers/api_key_info/auth_errors/expired_accountAPI', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(ShareUser.find(approved_share_user.id).approved).to be false
			end

			it "should mark APIs that return authorization errors as inactive" do
				VCR.use_cassette('workers/api_key_info/auth_errors/failedAuth_accountAPI', :allow_playback_repeats => true) do
					work.perform(share.id)
				end

				expect(Api.where("id = ?", approved_api.id)[0].active).to be false
			end

			it "should disapprove share_user's with main APIs that return authorization errors" do
				VCR.use_cassette('workers/api_key_info/auth_errors/failedAuth_accountAPI', :allow_playback_repeats => true) do
					work.perform(share.id)
				end
				expect(ShareUser.find(approved_share_user.id).approved).to be false
			end
		end
	end
end