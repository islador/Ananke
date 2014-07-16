# == Schema Information
#
# Table name: black_list_entity_logs
#
#  id                   :integer          not null, primary key
#  entity_name          :string(255)
#  source_share_user_id :integer
#  source_type          :integer
#  addition             :boolean
#  entity_type          :integer
#  date                 :date
#  time                 :datetime
#  share_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class BlackListEntityLog < ActiveRecord::Base
	
	validates :entity_name, presence: true
	validates :entity_type, presence: true
	validates :source_type, presence: true
	
	#Contains date/time rows as it is intended that whitelist log records be created asynchronously
	validates :date, presence: true
	validates :time, presence: true

	#The below validations are linked, ideally a custom validation should be made that ensures that the whitelist and the share_user belong to the same share.
	validates :share_id, presence: true
	validates :source_share_user_id, presence: true
end
