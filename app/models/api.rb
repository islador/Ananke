# == Schema Information
#
# Table name: apis
#
#  id                   :integer          not null, primary key
#  share_user_id        :integer
#  ccp_type             :integer
#  key_id               :string(255)
#  v_code               :string(255)
#  accessmask           :integer
#  active               :boolean
#  created_at           :datetime
#  updated_at           :datetime
#  main_entity_name     :string(255)
#  ananke_type          :integer
#  main                 :boolean
#  name                 :string(255)
#  whitelist_standings  :integer
#  black_list_standings :integer
#

class Api < ActiveRecord::Base
	#ccp_type: 1 corporation, 2 account, 3 character
	#ananke_type: 1 corporation, 2 general
	#main_entity_name: the name of the corporation if a corporation API, the name of the main character if this is a main API
	#main: is the main API true/false
	#A CCP Corp Key is always an Ananke Corp Key, A CCP Account Key is never an Ananke Corp Key, An Ananke Corp Key may be either a main or a general API, a CCP Account or Character Key may be either a main or a general Ananke Key.
	belongs_to :share_user
	has_many :characters, dependent: :destroy

	has_many :whitelist_api_connections, dependent: :destroy
	has_many :whitelists, through: :whitelist_api_connections

	has_many :black_list_entity_api_connections, dependent: :destroy
	has_many :black_list_entities, through: :black_list_entity_api_connections

	after_create :determine_type
	after_save :inform_share_user

	validates :key_id, presence: true#, uniqueness: true
	validates :v_code, presence: true

	#Below validations removed because they no longer work with the workflow. API's get this data from a sidekiq worker after creation.
	#validates :accessmask, presence: true
	#validates :active, presence: true
	#validates :entity, presence: true

	def retrieve_contact_list
		if(self.entity == 1)
			ContactListWorker.perform_async(self.key_id, self.v_code)
		else
			raise "API is not a corporation API (entity:1)"
		end
	end

	private 
	def determine_type
		ApiKeyInfoWorker.perform_async(self.id)
	end

	def inform_share_user
		self.share_user.maintain_share_user(self)
	end
end
