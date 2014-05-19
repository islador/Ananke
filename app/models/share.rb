# == Schema Information
#
# Table name: shares
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  owner_id   :integer
#  active     :boolean
#  user_limit :integer
#  grade      :integer
#  created_at :datetime
#  updated_at :datetime
#

class Share < ActiveRecord::Base
	#Grade: 1 = trial, 2 = basic, 3 = advanced, 4 = super
	
	has_many :share_users, dependent: :destroy
	has_many :users, through: :share_users

	validates :name, presence: true
	validates :owner_id, presence: true
	validates :user_limit, presence: true
	validates :grade, presence: true
end
