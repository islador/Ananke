# == Schema Information
#
# Table name: apis
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  entity     :integer
#  key_id     :string(255)
#  v_code     :string(255)
#  accessmask :integer
#  active     :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Api < ActiveRecord::Base
	#entity: 1 corporation, 2 character
	belongs_to :user
	has_many :characters

	validates :entity, presence: true
	validates :key_id, presence: true
	validates :v_code, presence: true
	validates :accessmask, presence: true
	validates :active, presence: true
end
