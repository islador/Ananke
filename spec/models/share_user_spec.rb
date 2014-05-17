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
#

require 'spec_helper'

describe ShareUser do
	let!(:share_user){FactoryGirl.create(:share_user)}

	subject{share_user}

	it {should respond_to(:share_id)}
	it {should respond_to(:user_id)}
	it {should respond_to(:user_role)}
	it {should respond_to(:main_char_name)}
	
	describe "Associations > " do
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
