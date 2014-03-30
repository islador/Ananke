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
#

class Character < ActiveRecord::Base
	belongs_to :api

	validates :name, presence: true
	validates :characterID, presence: true
	validates :corporationName, presence: true
	validates :corporationID, presence: true
	validates :allianceName, presence: true
	validates :allianceID, presence: true
	validates :factionName, presence: true
	validates :factionID, presence: true

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
