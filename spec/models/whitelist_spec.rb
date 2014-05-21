# == Schema Information
#
# Table name: whitelists
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  standing          :integer
#  entity_type       :integer
#  source_type       :integer
#  source_share_user :integer
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe Whitelist do
	let(:whitelist) {FactoryGirl.create(:whitelist)}

	subject {whitelist}

	it {should respond_to(:name)}
	it {should respond_to(:standing)}
	it {should respond_to(:entity_type)}
	it {should respond_to(:source_type)}
	it {should respond_to(:source_share_user)}

	it {should be_valid}

	describe "Associations > " do
		let!(:user) {FactoryGirl.create(:user)}
		let!(:share_user){FactoryGirl.create(:share_user, user_id: user.id)}
		let!(:api_whitelist) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, source_type: 1)}
		let!(:whitelist_api) {
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				FactoryGirl.create(:api, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235", share_user: share_user)
			end
		}
		let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: whitelist_api.id, whitelist_id: api_whitelist.id)}
		subject{api_whitelist}

		it {should respond_to(:apis)}

		it "api_whitelist.apis should yield whitelist_api" do
			whitelistDB = Whitelist.last
			whitelistDB.apis[0].id.should be whitelist_api.id
		end

		it "should destroy its whitelist_api_connections when destroyed" do
			api_whitelist.destroy
			WhitelistApiConnection.count.should be 0
		end	
	end

	describe "Callbacks > " do
		let!(:user) {FactoryGirl.create(:user)}
		let!(:share_user){FactoryGirl.create(:share_user, user_id: user.id)}
		
		it "on save it should create a whitelist log item" do
			
			expect{
				Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id)
				}.to change(WhitelistLog, :count).by(+1)
		end

		xit "on save, should create the correct log item" do
			Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id)
			expect{
				WhitelistLog.last
				}.to eq(WhitelistLog.new(entity_name: "Jack", addition: true, entity_type: 1, source_type: 2, source_share_user: share_user.id, date: Date.today, time: Time.new(2014)))
		end

		it "on destroy it should create a whitelist log item" do
			Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id)
			expect{
				Whitelist.last.destroy
				}.to change(WhitelistLog, :count).by(+1)
		end

		xit "on destroy it should create the correct whitelist log item" do
			Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id)
			Whitelist.last.destroy
			expect{
				WhitelistLog.last
				}.to eq(WhitelistLog.new(entity_name: "Jack", addition: false, entity_type: 1, source_type: 2, source_share_user: share_user.id, date: Date.today, time: Time.new(2014)))
		end

	end

	describe "Validations > " do
		describe "should validate presence of name" do
			before {whitelist.name = nil}
			it {should_not be_valid}
		end

		#describe "should validate presence of standing" do
		#	before {whitelist.standing = nil}
		#	it {should_not be_valid}
		#end

		describe "should validate presence of entity_type" do
			before {whitelist.entity_type = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of source_type" do
			before {whitelist.source_type = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of source_user" do
			before {whitelist.source_share_user = nil}
			it {should_not be_valid}
		end
	end

	describe "check_for_active_api_connections > " do
		let!(:user) {FactoryGirl.create(:user)}
		let!(:share_user){FactoryGirl.create(:share_user, user_id: user.id)}
		let!(:api_whitelist) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, source_type: 1)}
		
		it "should delete itself when check_for_active_api_connections is called and it is source_type 1 and lacks any api_connections" do
			api_whitelist.check_for_active_api_connections
			Whitelist.where("id = ?", api_whitelist.id)[0].should be_nil
		end
	end
end
