# == Schema Information
#
# Table name: whitelists
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  standing    :integer
#  entity_type :integer
#  source_type :integer
#  source_user :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Whitelist < ActiveRecord::Base

	has_many :whitelist_api_connections
	has_many :apis, through: :whitelist_api_connections

	#Should migrate name to entity_name for consistency if the chance is found.
	#ContactTypeIDs: 2=corporation, 16159=alliance, 1370-1390=character, ?=faction - presumed any other number
	#entity_type: 1 Alliance, 2 Corporation, 3 Faction, 4 Character
	#source_type: 1 API, 2 Manual
	validates :name, presence: true #It may be worthwhile to make name's unique and provide a proper error path for duplicates.
	#validates :standing, presence: true
	validates :entity_type, presence: true
	validates :source_type, presence: true
	validates :source_user, presence: true

	after_destroy :generate_removal_log
	after_save :generate_addition_log
	

	private
	#Creates a new whitelist log record representing itself being created.
	#This can be moved to sidekiq if necessary.
	def generate_addition_log
		WhitelistLog.create(entity_name: self.name, addition: true, entity_type: self.entity_type, source_type: self.source_type, source_user: self.source_user, date: Date.today, time: Time.now)
	end

	#Creates a new whitelist log record representing itself being destroyed.
	#This can be moved to sidekiq if necessary.
	def generate_removal_log
		WhitelistLog.create(entity_name: self.name, addition: false, entity_type: self.entity_type, source_type: self.source_type, source_user: self.source_user, date: Date.today, time: Time.now)
	end
end
