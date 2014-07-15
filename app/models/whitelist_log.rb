# == Schema Information
#
# Table name: whitelist_logs
#
#  id                :integer          not null, primary key
#  entity_name       :string(255)
#  source_share_user :integer
#  source_type       :integer
#  addition          :boolean
#  entity_type       :integer
#  date              :date
#  created_at        :datetime
#  updated_at        :datetime
#  time              :datetime
#  share_id          :integer
#

class WhitelistLog < ActiveRecord::Base
	#Contains date/time rows as it is intended that whitelist log records be created asynchronously
	validates :entity_name, presence: true
	validates :entity_type, presence: true
	validates :source_type, presence: true
	
	validates :date, presence: true
	validates :time, presence: true

	#The below validations are linked, ideally a custom validation should be made that ensures that the whitelist and the share_user belong to the same share.
	validates :share_id, presence: true
	validates :source_share_user, presence: true
end
