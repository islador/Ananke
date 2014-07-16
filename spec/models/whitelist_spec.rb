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
#  share_id          :integer
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
	it {should respond_to(:share_id)}

	it {should be_valid}

	describe "Associations > " do
		let(:user) {FactoryGirl.create(:user)}
		let(:share) {FactoryGirl.create(:share)}
		let!(:share_user){FactoryGirl.create(:share_user, user_id: user.id, share_id: share.id)}
		let!(:api_whitelist) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, source_type: 1, share_id: share.id)}
		let!(:whitelist_api) {
			VCR.use_cassette('workers/api_key_info/0characterAPI') do
				FactoryGirl.create(:api, v_code: "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x", key_id: "3255235", share_user: share_user)
			end
		}
		let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: whitelist_api.id, whitelist_id: api_whitelist.id, share_id: share.id)}
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
		let!(:share) {FactoryGirl.create(:share)}
		let!(:share_user){FactoryGirl.create(:share_user, user_id: user.id, share_id: share.id)}
		
		it "on save it should create a whitelist log item" do
			
			expect{
				Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id, share_id: share.id)
				}.to change(WhitelistLog, :count).by(+1)
		end

		it "on save, should create the correct log item" do
			expected = WhitelistLog.new(entity_name: "Jack", addition: true, entity_type: 1, source_type: 2, source_share_user: share_user.id, date: Date.today, time: Time.new(2014), share_id: share.id)
			Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id, share_id: share.id)
			log = WhitelistLog.last
			
			expect(log.entity_name).to eq(expected.entity_name)
			expect(log.addition).to eq(expected.addition)
			expect(log.entity_type).to eq(expected.entity_type)
			expect(log.source_type).to eq(expected.source_type)
			expect(log.source_share_user).to eq(expected.source_share_user)
			expect(log.date).to eq(expected.date)
			expect(log.share_id).to eq(expected.share_id)
			#Not comparing on time, not worth stubbing.
			#expect(log.time).to eq(expected.time)
		end

		it "on destroy it should create a whitelist log item" do
			Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id, share_id: share.id)
			expect{
				Whitelist.last.destroy
				}.to change(WhitelistLog, :count).by(+1)
		end

		it "on destroy it should create the correct whitelist log item" do
			expected = WhitelistLog.new(entity_name: "Jack", addition: false, entity_type: 1, source_type: 2, source_share_user: share_user.id, date: Date.today, time: Time.new(2014), share_id: share.id)
			target = Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: share_user.id, share_id: share.id)
			target.destroy

			log = WhitelistLog.last
			expect(log.entity_name).to eq(expected.entity_name)
			expect(log.addition).to eq(expected.addition)
			expect(log.entity_type).to eq(expected.entity_type)
			expect(log.source_type).to eq(expected.source_type)
			expect(log.source_share_user).to eq(expected.source_share_user)
			expect(log.date).to eq(expected.date)
			expect(log.share_id).to eq(expected.share_id)
			#Not comparing on time, not worth stubbing.
			#expect(log.time).to eq(expected.time)
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

		describe "should validate presence of share_id" do
			before {whitelist.share_id = nil}
			it {should_not be_valid}
		end
	end

	describe "check_for_active_api_connections > " do
		let!(:user) {FactoryGirl.create(:user)}
		let!(:share) {FactoryGirl.create(:share)}
		let!(:share_user){FactoryGirl.create(:share_user, user_id: user.id, share_id: share.id)}
		let!(:api_whitelist) {FactoryGirl.create(:whitelist, source_share_user: share_user.id, source_type: 1, share_id: share.id)}
		
		it "should delete itself when check_for_active_api_connections is called and it is source_type 1 and lacks any api_connections" do
			api_whitelist.check_for_active_api_connections
			Whitelist.where("id = ?", api_whitelist.id)[0].should be_nil
		end
	end
end
