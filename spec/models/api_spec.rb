# == Schema Information
#
# Table name: apis
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  ccp_type         :integer
#  key_id           :string(255)
#  v_code           :string(255)
#  accessmask       :integer
#  active           :boolean
#  created_at       :datetime
#  updated_at       :datetime
#  main_entity_name :string(255)
#  ananke_type      :integer
#  main             :boolean
#

require 'spec_helper'

describe Api do
	let(:user) {FactoryGirl.create(:user, :email => "user@example.com")}
	let(:api) {FactoryGirl.create(:api, user: user)}

	subject {api}

	it {should respond_to(:ccp_type)}
	it {should respond_to(:ananke_type)}
	it {should respond_to(:key_id)}
	it {should respond_to(:v_code)}
	it {should respond_to(:accessmask)}
	it {should respond_to(:active)}
	it {should respond_to(:main_entity_name)}
	it {should respond_to(:main)}

	it {should be_valid}

	describe "Associations > " do
		it "should belong to a user with email 'user@example.com'" do
			api.user.email.should match "user@example.com"
		end

		let!(:characterZeke) {FactoryGirl.create(:character, :api => api, :name => "Zeke")}
		let!(:characterJessica) {FactoryGirl.create(:character, :api => api, :name => "Jessica")}
		let!(:characterJeff) {FactoryGirl.create(:character, :api => api, :name => "Jeff")}

		it "should have a character named Zeke" do
			api.characters.should include(characterZeke)
		end

		it "should have a character named Jessica" do
			api.characters.should include(characterJessica)
		end

		it "should have a character named Jeff" do
			api.characters.should include(characterJeff)
		end
	end

	describe "Validations > " do
		#describe "should validate presence of entity" do
		#	before {api.entity = nil}
		#	it {should_not be_valid}
		#end

		describe "should validate presence of key_id" do
			before {api.key_id = nil}
			it {should_not be_valid}
		end

		describe "should validate presence of v_code" do
			before {api.v_code = nil}
			it {should_not be_valid}
		end

		#describe "should validate presence of accessmask" do
		#	before {api.accessmask = nil}
		#	it {should_not be_valid}
		#end

		#describe "should validate presence of active" do
		#	before {api.active = nil}
		#	it {should_not be_valid}
		#end
	end
end
