# == Schema Information
#
# Table name: whitelist_logs
#
#  id          :integer          not null, primary key
#  entity_name :string(255)
#  source_user :integer
#  source_type :integer
#  addition    :boolean
#  entity_type :integer
#  date        :date
#  created_at  :datetime
#  updated_at  :datetime
#  time        :datetime
#

class WhitelistLog < ActiveRecord::Base
	#Contains date/time rows as it is intended that whitelist log records be created asynchronously
	validates :entity_name, presence: true
	validates :entity_type, presence: true
	validates :source_type, presence: true
	validates :source_user, presence: true
	validates :date, presence: true
	validates :time, presence: true
end
