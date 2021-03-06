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

require 'spec_helper'

describe Share do
	let!(:share) {FactoryGirl.create(:basic_share)}

	subject{share}

	it {should respond_to(:name)}
	it {should respond_to(:owner_id)}
	it {should respond_to(:active)}
	it {should respond_to(:user_limit)}
	it {should respond_to(:grade)}
	it {should respond_to(:join_link)}

	it {should be_valid}

	describe "Associations > " do
		let(:user) {FactoryGirl.create(:user)}
		let!(:share_user) {FactoryGirl.create(:share_user, user_id: user.id, share_id: share.id)}

		it {should respond_to(:share_users)}

		it "should have user as a share_user" do
			share.share_users.where("id = ?", share_user.id)[0].should_not be_nil
		end

		it {should respond_to :users}

		it "should have a user" do
			share.users.where("user_id = ?", user.id)[0].should_not be_nil
		end
	end

	describe "Public Methods > " do
		describe "respect_share?(share_user)" do
			let!(:user_limit_share) {FactoryGirl.create(:share, user_limit: 2)}
			let!(:approved_share_user) {FactoryGirl.create(:share_user, approved: true, share_id: user_limit_share.id)}
			let!(:disapproved_share_user) {FactoryGirl.create(:share_user, approved: false, share_id: user_limit_share.id)}

			it "should return false if the share's user_limit would be exceeded by saving the passed in share_user" do
				disapproved_share_user.approved = true
				expect(user_limit_share.respect_share?(disapproved_share_user)).to be false
			end

			it "should return true if the share_user was approved, and will remain approved" do
				expect(user_limit_share.respect_share?(approved_share_user)).to be true
			end
		end
	end

	describe "Validations > " do
		describe "should validate presence of 'name'" do
			before {share.name = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of 'owner_id'" do
			before {share.owner_id = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of 'user_limit'" do
			before {share.user_limit = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of 'grade'" do
			before {share.grade = nil}
			it {should_not be_valid}
		end
	end
end
