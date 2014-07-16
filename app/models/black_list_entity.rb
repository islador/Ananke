# == Schema Information
#
# Table name: black_list_entities
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  standing             :integer
#  entity_type          :integer
#  source_type          :integer
#  source_share_user_id :integer
#  share_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class BlackListEntity < ActiveRecord::Base

	validates :name, presence: true
	#entity_type: 1 Alliance, 2 Corporation, 3 Faction, 4 Character, 5 API Pull
	validates :entity_type, presence: true
	#source_type: 1 API, 2 Manual
	validates :source_type, presence: true

	#The below validations are linked, ideally a custom validation should be made that ensures that the whitelist and the share_user belong to the same share.
	validates :source_share_user_id, presence: true
	validates :share_id, presence: true

	after_destroy :generate_removal_log
	after_save :generate_addition_log

	private
	#Creates a new whitelist log record representing itself being created.
	#This can be moved to sidekiq if necessary.
	def generate_addition_log
		BlackListEntityLog.create(entity_name: self.name, addition: true, entity_type: self.entity_type, source_type: self.source_type, source_share_user_id: self.source_share_user_id, date: Date.today, time: Time.now, share_id: self.share_id)
	end

	#Creates a new whitelist log record representing itself being destroyed.
	#This can be moved to sidekiq if necessary.
	def generate_removal_log
		BlackListEntityLog.create(entity_name: self.name, addition: false, entity_type: self.entity_type, source_type: self.source_type, source_share_user_id: self.source_share_user_id, date: Date.today, time: Time.now, share_id: self.share_id)
	end
end
