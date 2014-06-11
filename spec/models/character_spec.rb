# == Schema Information
#
# Table name: characters
#
#  id              :integer          not null, primary key
#  api_id          :integer
#  name            :string(255)
#  characterID     :integer
#  corporationName :string(255)
#  corporationID   :integer
#  allianceName    :string(255)
#  allianceID      :integer
#  factionName     :string(255)
#  factionID       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  main            :boolean
#  share_id        :integer
#

require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe Character do
	let(:share) {FactoryGirl.create(:share)}
	let(:share_user) {FactoryGirl.create(:share_user, share_id: share.id)}
	let!(:api) {
		VCR.use_cassette('workers/api_key_info/0characterAPI') do
			FactoryGirl.create(:api, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235", share_user: share_user)
		end
	}
	#FactoryGirl.create(:api)}
	let!(:character) {FactoryGirl.create(:character, api: api, name: "Zeke", share_id: share.id)}

	subject {character}

	it {should respond_to(:name)}
	it {should respond_to(:characterID)}
	it {should respond_to(:corporationName)}
	it {should respond_to(:corporationID)}
	it {should respond_to(:allianceName)}
	it {should respond_to(:allianceID)}
	it {should respond_to(:factionName)}
	it {should respond_to(:factionID)}
	it {should respond_to(:share_id)}

	it {should be_valid}

	describe "Associations > " do
		it "should belong to an API with key_id='api.key_id'" do
			character.api.key_id.should be api.key_id
		end
	end

	describe "Public API > " do
		describe "is_approved? > " do
			describe " true" do
				let!(:whitelistAlliance) {FactoryGirl.create(:whitelist, name: "Alliance", share_id: share.id)}
				let!(:characterAlliance) {FactoryGirl.create(:character, api: api, allianceName: "Alliance", share_id: share.id)}
				
				it "should return true if the character is in a whitelisted alliance" do
					characterAlliance.is_approved?.should be_true
				end

				let!(:whitelistCorporation) {FactoryGirl.create(:whitelist, name: "Corporation", share_id: share.id)}
				let!(:characterCorporation) {FactoryGirl.create(:character, api: api, corporationName: "Corporation", share_id: share.id)}
				
				it "should return true if the character is in a whitelisted corporation" do
					characterCorporation.is_approved?.should be_true
				end

				let!(:whitelistFaction) {FactoryGirl.create(:whitelist, name: "Faction", share_id: share.id)}
				let!(:characterFaction) {FactoryGirl.create(:character, api: api, factionName: "Faction", share_id: share.id)}
				
				it "should return true if the character is in a whitelisted faction" do
					characterFaction.is_approved?.should be_true
				end

				let!(:whitelistCharacter) {FactoryGirl.create(:whitelist, name: "Character", share_id: share.id)}
				let!(:characterCharacter) {FactoryGirl.create(:character, api: api, name: "Character", share_id: share.id)}
				
				it "should return true if the character is in a whitelisted character" do
					characterCharacter.is_approved?.should be_true
				end
			end
			describe "false" do
				let!(:whitelistAlliance) {FactoryGirl.create(:whitelist, name: "Alliance", share_id: share.id)}
				let!(:characterAlliance) {FactoryGirl.create(:character, api: api, allianceName: "NotAlliance", share_id: share.id)}
				
				it "should return false if the character is in a whitelisted alliance" do
					characterAlliance.is_approved?.should be_false
				end

				let!(:whitelistCorporation) {FactoryGirl.create(:whitelist, name: "Corporation", share_id: share.id)}
				let!(:characterCorporation) {FactoryGirl.create(:character, api: api, corporationName: "NotCorporation", share_id: share.id)}
				
				it "should return false if the character is in a whitelisted corporation" do
					characterCorporation.is_approved?.should be_false
				end

				let!(:whitelistFaction) {FactoryGirl.create(:whitelist, name: "Faction", share_id: share.id)}
				let!(:characterFaction) {FactoryGirl.create(:character, api: api, factionName: "NotFaction", share_id: share.id)}
				
				it "should return false if the character is in a whitelisted faction" do
					characterFaction.is_approved?.should be_false
				end

				let!(:whitelistCharacter) {FactoryGirl.create(:whitelist, name: "Character", share_id: share.id)}
				let!(:characterCharacter) {FactoryGirl.create(:character, api: api, name: "NotCharacter", share_id: share.id)}
				
				it "should return false if the character is in a whitelisted character" do
					characterCharacter.is_approved?.should be_false
				end
			end
		end
	end

	describe "Validations > " do
		describe "should validate presence of name" do
			before {character.name = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of characterID" do
			before {character.characterID = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of corporationName" do
			before {character.corporationName = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of corporationID" do
			before {character.corporationID = nil}
			it {should_not be_valid}
		end

		describe "should validate the presence of share_id" do
			before {character.share_id = nil}
			it {should_not be_valid}
		end
		
		describe "should validate name+share uniqueness" do
			#It is easier to compare characterID values then character names.
			let(:share_1) {FactoryGirl.create(:share)}
			let(:share_user_11) {FactoryGirl.create(:share_user, share_id: share_1.id)}
			let!(:api_11) {
				VCR.use_cassette('workers/api_key_info/0characterAPI') do
					FactoryGirl.create(:api, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235", share_user: share_user_11)
				end
			}
			let(:share_user_12) {FactoryGirl.create(:share_user, share_id: share_1.id)}
			let!(:api_12) {
				VCR.use_cassette('workers/api_key_info/0characterAPI') do
					FactoryGirl.create(:api, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235", share_user: share_user_12)
				end
			}

			let(:share_2) {FactoryGirl.create(:share)}
			let(:share_user_21) {FactoryGirl.create(:share_user, share_id: share_2.id)}
			let!(:api_21) {
				VCR.use_cassette('workers/api_key_info/0characterAPI') do
					FactoryGirl.create(:api, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235", share_user: share_user_21)
				end
			}
			it "should not allow two characters with the same characterID (easier to compare then name strings) on the same share" do
				char_1 = api_11.characters.build(name: "Jeffrey", characterID: 1234567890, corporationName: "Jeffrey Inc.", corporationID: 987654321, share_id: share_1.id)
				char_1.valid?.should be true
				if char_1.valid? == true
					char_1.save!
				end
				char_2 = api_12.characters.build(name: "Jeffrey", characterID: 1234567890, corporationName: "Jeffrey Inc.", corporationID: 987654321, share_id: share_1.id)
				char_2.valid?.should be false
				char_2.errors.messages[:characterID][0].should match "This character has already been registered"
			end

			it "should allow two characters with the same characterID (easier to compare then name strings) on two different shares" do
				char_1 = api_11.characters.build(name: "Jeffrey", characterID: 1234567890, corporationName: "Jeffrey Inc.", corporationID: 987654321, share_id: share_1.id)
				char_1.valid?.should be true
				if char_1.valid? == true
					char_1.save!
				end
				char_2 = api_21.characters.build(name: "Jeffrey", characterID: 1234567890, corporationName: "Jeffrey Inc.", corporationID: 987654321, share_id: share_2.id)
				char_2.valid?.should be true
			end
		end
	end
end
