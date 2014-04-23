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
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe WhitelistApiConnection do
	let!(:user) {FactoryGirl.create(:user)}
	let!(:api) {
		VCR.use_cassette('workers/api_key_info/characterAPI') do
			FactoryGirl.create(:api, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235", user: user)
		end
	}
	let!(:whitelist_entity) {FactoryGirl.create(:whitelist, source_type: 1, source_user: user.id)}
	let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: api.id, whitelist_id: whitelist_entity.id)}

	subject {whitelist_api_connection}

	it {should be_valid}

	it {should respond_to(:api_id)}
	it {should respond_to(:whitelist_id)}

	describe "Associations > " do
		it "should have an API" do
			whitelist_api_connection.api.id.should be api.id
		end

		it "should have a whitelist" do
			whitelist_api_connection.whitelist.id.should be whitelist_entity.id
		end

		it "should get deleted when the API it is associated with gets deleted" do
			api.destroy
			WhitelistApiConnection.count.should be 0
		end

		it "should get deleted when the Whitelist it is associated with gets deleted" do
			whitelist_entity.destroy
			WhitelistApiConnection.count.should be 0
		end
	end

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
