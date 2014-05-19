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

require 'spec_helper'

describe ShareUser do
	let(:owner) {FactoryGirl.create(:user)}
	let(:user) {FactoryGirl.create(:user)}
	let(:share) {FactoryGirl.create(:basic_share, owner_id: owner.id)}
	let!(:share_user){FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}

	subject{share_user}

	it {should respond_to(:share_id)}
	it {should respond_to(:user_id)}
	it {should respond_to(:user_role)}
	it {should respond_to(:main_char_name)}
	it {should respond_to(:valid)}
	
	describe "Associations > " do
		it "should have a user" do
			share_user.user.id.should_not be_nil
		end

		it "should have a share" do
			share_user.share.id.should_not be_nil
		end

		it "should get deleted when the user it is associated with gets deleted" do
			user.destroy
			ShareUser.where("user_id = ?", user.id)[0].should be_nil
		end

		it "should get deleted when the share it is associated with gets deleted" do
			share.destroy
			ShareUser.where("share_id = ?", share.id)[0].should be_nil
		end
	end

	describe "Validations > " do
		describe "should validate presence of 'share_id'" do
			before {share_user.share_id = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of 'user_id'" do
			before {share_user.user_id = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of 'user_role'" do
			before {share_user.user_role = nil}
			it {should_not be_valid}
		end
	end
end
