# == Schema Information
#
# Table name: black_list_entity_api_connections
#
#  id                   :integer          not null, primary key
#  api_id               :integer
#  black_list_entity_id :integer
#  share_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class BlackListEntityApiConnection < ActiveRecord::Base
	
	belongs_to :api
	belongs_to :black_list_entity

	after_destroy :check_black_list_entity

	validates :api_id, presence: true
	validates :black_list_entity_id, presence: true
	validates :share_id, presence: true

	def check_black_list_entity
		self.black_list_entity.check_for_active_api_connections
	end
end
