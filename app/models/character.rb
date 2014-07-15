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
	def approve_character?
		share_id = self.api.share_user.share_id
		#Check the alliance, as it is most likely to be true.
		if(Whitelist.where("name = ? AND share_id = ?", self.allianceName, share_id)[0].nil? == false)
			#self.api.share_user.approved = true
			return true
			#Check the corporation next
		elsif(Whitelist.where("name = ? AND share_id = ?", self.corporationName, share_id)[0].nil? == false)
			#self.api.share_user.approved = true
			return true
			#Check the Faction next
		elsif(Whitelist.where("name = ? AND share_id = ?", self.factionName, share_id)[0].nil? == false)
			#self.api.share_user.approved = true
			return true
			#Check the character name last
		elsif Whitelist.where("name = ? AND share_id = ?", self.name, share_id)[0].nil? == false
			#self.api.share_user.approved = true
			return true
		else
			self.api.share_user.approved = false
			return false
		end
		#self.api.share_user.save
	end
end
