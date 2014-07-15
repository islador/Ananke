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
#  join_link  :string(255)
#

class Share < ActiveRecord::Base
	#Grade: 1 = trial, 2 = basic, 3 = advanced, 4 = super
	
	has_many :share_users, foreign_key: "share_id", dependent: :destroy
	has_many :users, through: :share_users

	validates :name, presence: true
	validates :owner_id, presence: true
	validates :user_limit, presence: true
	validates :grade, presence: true

	#A method to determine if a given share_user would defy the share's rules
	def respect_share?(share_user)
		#Ensure the share's user_limit is respected.
		if share_user.approved == true
			#if the share_user is not new and was previously approved
			if share_user.id != nil && ShareUser.find(share_user.id).approved == true
				#Edge Case: If the ShareUser started approved, and the new save would also leave it approved, the approved share_user count would not increase. Thus we return true.
				return true
			else
				count = self.share_users.where("approved = true").count
				#This assumes that in the event this returns true, the share_user will be added to the share.
				#Thus it must count up, so that a share with 10 users and a 10 user limit will return false.
				if count+1<=self.user_limit
					return true
				else
					return false
				end
			end
		end
		#This method can be expanded as the share grows.
	end
end
