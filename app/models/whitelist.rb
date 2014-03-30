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

	#Should migrate name to entity_name for consistency if the chance is found.
	validates :name, presence: true
	validates :standing, presence: true
	validates :entity_type, presence: true
	validates :source_type, presence: true
	validates :source_user, presence: true

	after_destroy :generate_removal_log
	after_save :generate_addition_log
	

	private
	#Creates a new whitelist log record representing itself being created.
	#This can be moved to sidekiq if necessary.
	def generate_addition_log
		#SOURCE USER IS STUBBED, IT NEEDS TO BE FIXED
		WhitelistLog.create(entity_name: self.name, addition: true, entity_type: self.entity_type, source_type: self.source_type, source_user: 1, date: Date.today, time: Time.now)
	end

	#Creates a new whitelist log record representing itself being destroyed.
	#This can be moved to sidekiq if necessary.
	def generate_removal_log
		#SOURCE USER IS STUBBED, IT NEEDS TO BE FIXED
		fuck = WhitelistLog.new(entity_name: self.name, addition: false, entity_type: self.entity_type, source_type: self.source_type, source_user: 1, date: Date.today, time: Time.now)
		fuck.save!
	end
end
