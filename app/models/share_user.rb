# == Schema Information
#
# Table name: share_users
#
#  id             :integer          not null, primary key
#  share_id       :integer
#  user_id        :integer
#  user_role      :integer
#  main_char_name :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  approved       :boolean
#

class ShareUser < ActiveRecord::Base
	#user_role: Expected to be a bitmask, not sure if it'll represent permissions or roles yet.
	belongs_to :user
	belongs_to :share
	has_many :apis, dependent: :destroy

	validates :share_id, presence: true
	validates :user_id, presence: true
	validates :user_role, presence: true

	validates_with RespectShareValidator

	def maintain_share_user(api)
		if api.main == true && api.active == false
			self.approved = false
			self.save
		end
	end
end
