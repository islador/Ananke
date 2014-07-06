# == Schema Information
#
# Table name: characters
#
#  id                 :integer          not null, primary key
#  api_id             :integer
#  name               :string(255)
#  ccp_character_id   :integer
#  corporationName    :string(255)
#  ccp_corporation_id :integer
#  allianceName       :string(255)
#  ccp_alliance_id    :integer
#  factionName        :string(255)
#  ccp_faction_id     :integer
#  created_at         :datetime
#  updated_at         :datetime
#  main               :boolean
#  share_id           :integer
#

class Character < ActiveRecord::Base
	belongs_to :api
	#The main bool is intended to be used to identify the main character of an account's main API. There doesn't seem to be a way to enforce it being false in other situations inherent in rails.

	#Characters must be unique on a given share. This requires a custom validater to determine that.
	#Characters on corp APIs create potential conflicts.
	validates :name, presence: true
	validates :ccp_character_id, presence: true, uniqueness: {scope: :share_id, message: "This character has already been registered"}
	validates :corporationName, presence: true
	validates :ccp_corporation_id, presence: true
	validates :share_id, presence: true

	#The API can return null values, so validating these presences seems a bit off.
	#validates :allianceName, presence: true
	#validates :allianceID, presence: true
	#validates :factionName, presence: true
	#validates :factionID, presence: true

	#Check the whitelist to see if the character is on the list in one capacity or another.
	def is_approved?
		#Check the alliance, as it is most likely to be true.
		if(Whitelist.where("name = ?", self.allianceName)[0].nil? == false)
			return true
		end
		#Check the corporation next
		if(Whitelist.where("name = ?", self.corporationName)[0].nil? == false)
			return true
		end
		#Check the Faction next
		if(Whitelist.where("name = ?", self.factionName)[0].nil? == false)
			return true
		end
		#Check the character name last
		if(Whitelist.where("name = ?", self.name)[0].nil? == false)
			return true
		end
		#Implicit else, return false
		return false
	end
end
