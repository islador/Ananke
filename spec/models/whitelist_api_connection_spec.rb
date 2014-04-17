# == Schema Information
#
# Table name: whitelist_api_connections
#
#  id           :integer          not null, primary key
#  api_id       :integer
#  whitelist_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe WhitelistApiConnection do
	#let!(:user) {FactoryGirl.create(:user)}
	#let!(:api) {FactoryGirl.create(:api, user: user)}
	#let!(:whitelist_entity) {FactoryGirl.create(:whitelist, source_type: 1, source_user: user.id)}
	let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection)}

	subject {whitelist_api_connection}

	it {should be_valid}

	it {should respond_to(:api_id)}
	it {should respond_to(:whitelist_id)}

	describe "Validations > " do
		describe "should validate presence of whitelist_id" do
			before{whitelist_api_connection.whitelist_id = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of api_id" do
			before{whitelist_api_connection.api_id = nil}
			it {should_not be_valid}
		end
	end
end
