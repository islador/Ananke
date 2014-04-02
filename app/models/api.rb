# == Schema Information
#
# Table name: apis
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  entity      :integer
#  key_id      :string(255)
#  v_code      :string(255)
#  accessmask  :integer
#  active      :boolean
#  created_at  :datetime
#  updated_at  :datetime
#  main_entity :string(255)
#

class Api < ActiveRecord::Base
	#entity: 1 corporation, 2 character
	belongs_to :user
	has_many :characters

	after_create :determine_type
	#Add a main_entity column?
	# Could be used to allow for main character functionality as well as allowing for corporation name's to be displayed for corporation APIs?

	validates :entity, presence: true
	validates :key_id, presence: true
	validates :v_code, presence: true
	validates :accessmask, presence: true
	#validates :active, presence: true

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
