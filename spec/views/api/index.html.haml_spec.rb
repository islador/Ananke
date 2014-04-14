require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe "api/index.html.haml > " do
	let!(:user) {FactoryGirl.create(:user)}
	Capybara.default_wait_time = 10

	subject {page}

	before(:each) do
		visit user_api_index_path(user)
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
		visit user_api_index_path(user)
	end

	it "should contain an explanation of terms" do
		should have_selector('div.explanation')
	end

	it "should contain a table of the user's APIs" do
		should have_selector('#api_list_table')
	end

	it "should render datatables for the user's api table", js: true do
		should have_selector('#api_list_table_wrapper')
	end

	it "should have two 'Enroll new API' buttons" do
		should have_selector('#enroll_new_api_1')
		should have_selector('#enroll_new_api_2')
	end

	describe "Api List Table > " do
		let!(:api) {FactoryGirl.create(:api, user: user, main_entity_name: "Jeff")}
		it "should contain items from the database" do
			visit user_api_index_path(user)
			within '#api_list_table' do
				should have_selector("tr#api_#{api.id}", text: api.main_entity_name)
			end
		end

		let!(:api1) {FactoryGirl.create(:api, user: user)}
		let!(:api2) {FactoryGirl.create(:api, user: user)}
		it "should contain a delete button for each non main api" do
			visit user_api_index_path(user)
			should have_selector("button#destroy_api_#{api1.id}", text: "Delete")
		end

		let!(:api) {FactoryGirl.create(:api, user: user, main: true)}
		let!(:character) {FactoryGirl.create(:character, api: api)}
		it "should not have a delete button for the main API" do
			visit user_api_index_path(user)
			should_not have_selector("button#destroy_api_#{api.id}", text: "Delete")
		end

		let!(:api) {FactoryGirl.create(:api, user: user, main: true)}
		let!(:api1) {FactoryGirl.create(:api, user: user, main: false)}
		it "should have a 'Set as Main API' button for non-main APIs" do
			visit user_api_index_path(user)
			should have_selector("button#set_main_api_#{api1.id}", text: "Set as Main API")
		end
	end

	describe "Delete > " do
		let!(:api) {FactoryGirl.create(:api, main_entity_name: "Jeff")}
		it "should remove the item from the datatable when clicked", js: true do
			visit user_api_index_path(user)
			
			should have_selector("tr#api_#{api.id}", text: api.main_entity_name)
			
			#http://stackoverflow.com/a/2609244
			page.evaluate_script('window.confirm = function() { return true; }')

			click_button 'Delete'
			should_not have_selector("tr#api_#{api.id}", text: api.main_entity_name)
		end
	end
end
