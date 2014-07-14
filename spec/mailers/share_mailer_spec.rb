require "spec_helper"

describe ShareMailer do
	describe "user_limit_exceeded > " do
		let!(:share_user) {FactoryGirl.create(:share_user, approved: false)}

		xit "should retrieve the parent share from the share_user" do
		end
	end
end
