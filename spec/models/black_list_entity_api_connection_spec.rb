# == Schema Information
#
# Table name: black_list_entity_api_connections
#
#  id                   :integer          not null, primary key
#  api_id               :integer
#  black_list_entity_id :integer
#  share_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#

require 'spec_helper'

describe BlackListEntityApiConnection do
	let(:user) {FactoryGirl.create(:user)}
	let(:share) {FactoryGirl.create(:share)}
	let(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}
	let(:api) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
	let(:black_list_entity) {FactoryGirl.create(:black_list_entity, source_share_user_id: share_user.id, share_id: share.id)}
	let!(:black_list_entity_api_connection) {FactoryGirl.create(:black_list_entity_api_connection, api_id: api.id, black_list_entity_id: black_list_entity.id, share_id: share.id)}

	let!(:api2) {FactoryGirl.create(:corp_api_skip_determine_type, share_user: share_user)}
	let!(:black_list_entity2) {FactoryGirl.create(:black_list_entity, source_type: 1, source_share_user_id: share_user.id, share_id: share.id)}
	let!(:black_list_entity2_api2_connection) {FactoryGirl.create(:black_list_entity_api_connection, api_id: api2.id, black_list_entity_id: black_list_entity2.id, share_id: share.id)}
	let!(:black_list_entity2_api_connection) {FactoryGirl.create(:black_list_entity_api_connection, api_id: api.id, black_list_entity_id: black_list_entity2.id, share_id: share.id)}

	subject {black_list_entity_api_connection}

	it {should respond_to(:api_id)}
	it {should respond_to(:black_list_entity_id)}
	it {should respond_to(:share_id)}

	describe "Associations > " do
		it "should have an API" do
			black_list_entity_api_connection.api.id.should be api.id
		end

		it "should have a whitelist" do
			black_list_entity_api_connection.black_list_entity.id.should be black_list_entity.id
		end

		it "should get deleted when the API it is associated with gets deleted" do
			api.destroy
			expect(BlackListEntityApiConnection.where("id = ?", black_list_entity_api_connection.id)[0]).to be_nil
		end

		it "should get deleted when the Whitelist it is associated with gets deleted" do
			black_list_entity.destroy
			expect(BlackListEntityApiConnection.where("id = ?", black_list_entity_api_connection.id)[0]).to be_nil
		end

		it "should destroy invalid whitelist objects when destroyed." do
			black_list_entity_api_connection.destroy
			expect(BlackListEntity.where("id = ?", black_list_entity.id)[0]).to be_nil
		end

		it "should not destroy valid whitelist objects when destroyed." do
			api.destroy
			expect(BlackListEntity.where("id = ?", black_list_entity.id)[0]).to be_nil
			expect(BlackListEntity.where("id = ?", black_list_entity2.id)[0]).to_not be_nil
		end
	end
end
