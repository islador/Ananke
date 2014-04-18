# == Schema Information
#
# Table name: apis
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  ccp_type            :integer
#  key_id              :string(255)
#  v_code              :string(255)
#  accessmask          :integer
#  active              :boolean
#  created_at          :datetime
#  updated_at          :datetime
#  main_entity_name    :string(255)
#  ananke_type         :integer
#  main                :boolean
#  name                :string(255)
#  whitelist_standings :integer
#

class Api < ActiveRecord::Base
	#ccp_type: 1 corporation, 2 account, 3 character
	#ananke_type: 1 corporation, 2 general
	#main_entity_name: the name of the corporation if a corporation API, the name of the main character if this is a main API
	#main: is the main API true/false
	#A CCP Corp Key is always an Ananke Corp Key, A CCP Account Key is never an Ananke Corp Key, An Ananke Corp Key may be either a main or a general API, a CCP Account or Character Key may be either a main or a general Ananke Key.
	belongs_to :user
	has_many :characters, dependent: :destroy
	has_many :whitelist_api_connections
	has_many :whitelists, through: :whitelist_api_connections

	after_create :determine_type
	
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

	def determine_type
		ApiKeyInfoWorker.perform_async(self.key_id, self.v_code)
	end

	#Point of optimization. This method could take the Api model as an arguemtn, do its thing, then save it. Thus avoiding a DB access in certain situations.
	def set_main_entity_name
		#Throw an error if the API is not a main API
		raise ArgumentError, "Api must be a main API to have a main entity name." if self.main != true
		#If the API is a corporation API, append the main character's name infront of the corporation name
		if self.ananke_type == 1
			self.main_entity_name = self.characters.where("main = true")[0].name + " - " + self.main_entity_name
		#If the api is a general API, set the main_entity_name value to the API's main character.
		elsif self.ananke_type == 2
			self.main_entity_name = self.characters.where("main = true")[0].name
		end
		self.save
	end
end
