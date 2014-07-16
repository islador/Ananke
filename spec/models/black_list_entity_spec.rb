# == Schema Information
#
# Table name: black_list_entities
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  standing             :integer
#  entity_type          :integer
#  source_type          :integer
#  source_share_user_id :integer
#  share_id             :integer
#  created_at           :datetime
#  updated_at           :datetime
#

require 'spec_helper'

describe BlackListEntity do
	let(:blacklist) {FactoryGirl.create(:black_list_entity)}
	subject {blacklist}

	it {should respond_to(:name)}
	it {should respond_to(:standing)}
	it {should respond_to(:entity_type)}
	it {should respond_to(:source_type)}
	it {should respond_to(:source_share_user_id)}
	it {should respond_to(:share_id)}

	it {should be_valid}

	describe "Callbacks > " do
		let!(:user) {FactoryGirl.create(:user)}
		let!(:share) {FactoryGirl.create(:share)}
		let!(:share_user){FactoryGirl.create(:share_user, user_id: user.id, share_id: share.id)}
		
		it "on save it should create a whitelist log item" do
			
			expect{
				BlackListEntity.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user_id: share_user.id, share_id: share.id)
				}.to change(BlackListEntityLog, :count).by(+1)
		end

		it "on save, should create the correct log item" do
			expected = BlackListEntityLog.new(entity_name: "Jack", addition: true, entity_type: 1, source_type: 2, source_share_user_id: share_user.id, date: Date.today, time: Time.new(2014), share_id: share.id)
			BlackListEntity.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user_id: share_user.id, share_id: share.id)
			log = BlackListEntityLog.last
			
			expect(log.entity_name).to eq(expected.entity_name)
			expect(log.addition).to eq(expected.addition)
			expect(log.entity_type).to eq(expected.entity_type)
			expect(log.source_type).to eq(expected.source_type)
			expect(log.source_share_user_id).to eq(expected.source_share_user_id)
			expect(log.date).to eq(expected.date)
			expect(log.share_id).to eq(expected.share_id)
			#Not comparing on time, not worth stubbing.
			#expect(log.time).to eq(expected.time)
		end

		it "on destroy it should create a whitelist log item" do
			BlackListEntity.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user_id: share_user.id, share_id: share.id)
			expect{
				BlackListEntity.last.destroy
				}.to change(BlackListEntityLog, :count).by(+1)
		end

		it "on destroy it should create the correct whitelist log item" do
			expected = BlackListEntityLog.new(entity_name: "Jack", addition: false, entity_type: 1, source_type: 2, source_share_user_id: share_user.id, date: Date.today, time: Time.new(2014), share_id: share.id)
			target = BlackListEntity.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user_id: share_user.id, share_id: share.id)
			target.destroy

			log = BlackListEntityLog.last
			expect(log.entity_name).to eq(expected.entity_name)
			expect(log.addition).to eq(expected.addition)
			expect(log.entity_type).to eq(expected.entity_type)
			expect(log.source_type).to eq(expected.source_type)
			expect(log.source_share_user_id).to eq(expected.source_share_user_id)
			expect(log.date).to eq(expected.date)
			expect(log.share_id).to eq(expected.share_id)
			#Not comparing on time, not worth stubbing.
			#expect(log.time).to eq(expected.time)
		end
	end
end
