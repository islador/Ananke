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
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe ShareUser do
	let(:owner) {FactoryGirl.create(:user)}
	let(:user) {FactoryGirl.create(:user)}
	let(:share) {FactoryGirl.create(:basic_share, owner_id: owner.id)}
	let!(:share_user){FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id, approved: false)}

	subject{share_user}

	it {should respond_to(:share_id)}
	it {should respond_to(:user_id)}
	it {should respond_to(:user_role)}
	it {should respond_to(:main_char_name)}
	it {should respond_to(:approved)}
	
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

	describe "Public Methods > " do
		describe "maintain_share_user(api)" do
			let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id, approved: true)}

			let!(:api) {FactoryGirl.create(:character_api_skip_determine_type, share_user: share_user, main: true, active: true)}

			it "should set the share_user to disapproved if the API passed in is an inactive main API" do
				api.active=false
				
				share_user.maintain_share_user(api)
				expect(ShareUser.find(share_user.id).approved).to be false
			end
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

		describe "RespectShareValidator" do
			let!(:user_limit_share) {FactoryGirl.create(:share, user_limit: 1)}
			let!(:disapproved_share_user) {FactoryGirl.create(:share_user, approved: false, share_id: user_limit_share.id)}

			it "should not be valid if approving it would exceed the share's user_limit" do
				disapproved_share_user.approved = true

				expect(disapproved_share_user.valid?).to_not be_true
			end
		end			
	end
end
