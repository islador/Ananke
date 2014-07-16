# == Schema Information
#
# Table name: whitelist_api_connections
#
#  id           :integer          not null, primary key
#  api_id       :integer
#  whitelist_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  share_id     :integer
#

require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe WhitelistApiConnection do
	let!(:user) {FactoryGirl.create(:user)}
	let(:share) {FactoryGirl.create(:share)}
	let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}
	let!(:api) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
	let!(:whitelist_entity) {FactoryGirl.create(:whitelist, source_type: 1, source_share_user: share_user.id, share_id: share.id)}
	let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: api.id, whitelist_id: whitelist_entity.id, share_id: share.id)}

	let!(:api2) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
	let!(:whitelist_entity2) {FactoryGirl.create(:whitelist, source_type: 1, source_share_user: share_user.id, share_id: share.id)}
	let!(:whitelist_api_connection_api2_whitelist_entity2) {FactoryGirl.create(:whitelist_api_connection, api_id: api2.id, whitelist_id: whitelist_entity2.id, share_id: share.id)}
	let!(:whitelist_api_connection_api_whitelist_entity2) {FactoryGirl.create(:whitelist_api_connection, api_id: api.id, whitelist_id: whitelist_entity2.id, share_id: share.id)}

	subject {whitelist_api_connection}

	it {should be_valid}

	it {should respond_to(:api_id)}
	it {should respond_to(:whitelist_id)}
	it {should respond_to(:share_id)}

	describe "Associations > " do
		it "should have an API" do
			whitelist_api_connection.api.id.should be api.id
		end

		it "should have a whitelist" do
			whitelist_api_connection.whitelist.id.should be whitelist_entity.id
		end

		it "should get deleted when the API it is associated with gets deleted" do
			api.destroy
			WhitelistApiConnection.where("id = ?", whitelist_api_connection.id)[0].should be_nil
		end

		it "should get deleted when the Whitelist it is associated with gets deleted" do
			whitelist_entity.destroy
			WhitelistApiConnection.where("id = ?", whitelist_api_connection.id)[0].should be_nil
		end

		it "should destroy invalid whitelist objects when destroyed." do
			whitelist_api_connection.destroy
			Whitelist.where("id = ?", whitelist_entity.id)[0].should be_nil
		end

		it "should not destroy valid whitelist objects when destroyed." do
			api.destroy
			Whitelist.where("id = ?", whitelist_entity.id)[0].should be_nil
			Whitelist.where("id = ?", whitelist_entity2.id)[0].should_not be_nil
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

		describe "should validate the presnce of share_id" do
			before{whitelist_api_connection.share_id = nil}
			it {should_not be_valid}
		end
	end
end
