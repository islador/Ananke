# == Schema Information
#
# Table name: whitelists
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  standing          :integer
#  entity_type       :integer
#  source_type       :integer
#  source_share_user :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class Whitelist < ActiveRecord::Base

	has_many :whitelist_api_connections, dependent: :destroy
	has_many :apis, through: :whitelist_api_connections

	#Should migrate name to entity_name for consistency if the chance is found.
	#ContactTypeIDs: 2=corporation, 16159=alliance, 1370-1390=character, ?=faction - presumed any other number
	#entity_type: 1 Alliance, 2 Corporation, 3 Faction, 4 Character, 5 API Pull
	#source_type: 1 API, 2 Manual
	validates :name, presence: true #It may be worthwhile to make name's unique and provide a proper error path for duplicates.
	#validates :standing, presence: true
	validates :entity_type, presence: true
	validates :source_type, presence: true
	validates :source_share_user, presence: true

	after_destroy :generate_removal_log
	after_save :generate_addition_log
	
	#Destroy itself if it no longer has any whitelist_api_connections and it is an API sourced whitelist entity
	def check_for_active_api_connections
		if self.source_type == 1 && self.whitelist_api_connections.count == 0
			self.destroy
		end
	end

	private
	#Creates a new whitelist log record representing itself being created.
	#This can be moved to sidekiq if necessary.
	def generate_addition_log
		WhitelistLog.create(entity_name: self.name, addition: true, entity_type: self.entity_type, source_type: self.source_type, source_share_user: self.source_share_user, date: Date.today, time: Time.now)
	end

	#Creates a new whitelist log record representing itself being destroyed.
	#This can be moved to sidekiq if necessary.
	def generate_removal_log
		WhitelistLog.create(entity_name: self.name, addition: false, entity_type: self.entity_type, source_type: self.source_type, source_share_user: self.source_share_user, date: Date.today, time: Time.now)
	end
end
