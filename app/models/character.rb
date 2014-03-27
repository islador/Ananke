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
end
