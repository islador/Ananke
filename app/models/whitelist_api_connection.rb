# == Schema Information
#
# Table name: whitelist_api_connections
#
#  id           :integer          not null, primary key
#  api_id       :integer
#  whitelist_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class WhitelistApiConnection < ActiveRecord::Base

	belongs_to :api
	belongs_to :whitelist

	after_destroy :check_whitelist

	validates :api_id, presence: true
	validates :whitelist_id, presence: true

	def check_whitelist
		self.whitelist.check_for_active_api_connections
	end
end
