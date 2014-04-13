# == Schema Information
#
# Table name: apis
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  ccp_type         :integer
#  key_id           :string(255)
#  v_code           :string(255)
#  accessmask       :integer
#  active           :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  main_entity_name :string(255)
#  ananke_type      :integer
#  main             :boolean
#  name             :string(255)
#

class Api < ActiveRecord::Base
	#ccp_type: 1 corporation, 2 account, 3 character
	#ananke_type: 1 corporation, 2 general
	#main_entity_name: the name of the corporation if a corporation API, the name of the main character if this is a main API
	#main: is the main API true/false
	belongs_to :user
	has_many :characters, dependent: :destroy

	after_create :determine_type
	#Add a main_entity column?
	# Could be used to allow for main character functionality as well as allowing for corporation name's to be displayed for corporation APIs?

	
	validates :key_id, presence: true
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
end
