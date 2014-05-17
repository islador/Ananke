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
	validates :name, presence: true
	validates :owner_id, presence: true
	validates :user_limit, presence: true
	validates :grade, presence: true
end
