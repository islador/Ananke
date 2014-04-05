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
#

require 'spec_helper'

describe Character do
	let(:api) {FactoryGirl.create(:api, :key_id => 7654321)}
	let(:character) {FactoryGirl.create(:character, :api => api, :name => "Zeke")}

	subject {character}

	it {should respond_to(:name)}
	it {should respond_to(:characterID)}
	it {should respond_to(:corporationName)}
	it {should respond_to(:corporationID)}
	it {should respond_to(:allianceName)}
	it {should respond_to(:allianceID)}
	it {should respond_to(:factionName)}
	it {should respond_to(:factionID)}

	it {should be_valid}

	describe "Associations > " do
		it "should belong to an API with key_id='7654321'" do
			character.api.key_id.should be 7654321
		end
	end

	describe "Public API > " do
		describe "is_approved? > " do
			describe " true" do
				let!(:whitelistAlliance) {FactoryGirl.create(:whitelist, name: "Alliance")}
				let!(:characterAlliance) {FactoryGirl.create(:character, allianceName: "Alliance")}
				
				it "should return true if the character is in a whitelisted alliance" do
					characterAlliance.is_approved?.should be_true
				end

				let!(:whitelistCorporation) {FactoryGirl.create(:whitelist, name: "Corporation")}
				let!(:characterCorporation) {FactoryGirl.create(:character, corporationName: "Corporation")}
				
				it "should return true if the character is in a whitelisted corporation" do
					characterCorporation.is_approved?.should be_true
				end

				let!(:whitelistFaction) {FactoryGirl.create(:whitelist, name: "Faction")}
				let!(:characterFaction) {FactoryGirl.create(:character, factionName: "Faction")}
				
				it "should return true if the character is in a whitelisted faction" do
					characterFaction.is_approved?.should be_true
				end

				let!(:whitelistCharacter) {FactoryGirl.create(:whitelist, name: "Character")}
				let!(:characterCharacter) {FactoryGirl.create(:character, name: "Character")}
				
				it "should return true if the character is in a whitelisted character" do
					characterCharacter.is_approved?.should be_true
				end
			end
			describe "false" do
				let!(:whitelistAlliance) {FactoryGirl.create(:whitelist, name: "Alliance")}
				let!(:characterAlliance) {FactoryGirl.create(:character, allianceName: "NotAlliance")}
				
				it "should return false if the character is in a whitelisted alliance" do
					characterAlliance.is_approved?.should be_false
				end

				let!(:whitelistCorporation) {FactoryGirl.create(:whitelist, name: "Corporation")}
				let!(:characterCorporation) {FactoryGirl.create(:character, corporationName: "NotCorporation")}
				
				it "should return false if the character is in a whitelisted corporation" do
					characterCorporation.is_approved?.should be_false
				end

				let!(:whitelistFaction) {FactoryGirl.create(:whitelist, name: "Faction")}
				let!(:characterFaction) {FactoryGirl.create(:character, factionName: "NotFaction")}
				
				it "should return false if the character is in a whitelisted faction" do
					characterFaction.is_approved?.should be_false
				end

				let!(:whitelistCharacter) {FactoryGirl.create(:whitelist, name: "Character")}
				let!(:characterCharacter) {FactoryGirl.create(:character, name: "NotCharacter")}
				
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

		describe "should validate presence of allianceName" do
			before {character.allianceName = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of allianceID" do
			before {character.allianceID = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of factionName" do
			before {character.factionName = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of factionID" do
			before {character.factionID = nil}
			it {should_not be_valid}
		end
	end
end
