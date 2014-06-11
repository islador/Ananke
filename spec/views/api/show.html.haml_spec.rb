require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe "api/show.html.haml" do
	let(:user) {FactoryGirl.create(:user)}
	let(:share) {FactoryGirl.create(:share)}
	let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}
	Capybara.default_wait_time = 10

	subject {page}

	let!(:api) {
		VCR.use_cassette('workers/api_key_info/0characterAPI') do
			FactoryGirl.create(:api, share_user: share_user)
		end
	}
	let!(:main_api) {
		VCR.use_cassette('workers/api_key_info/0characterAPI') do
			FactoryGirl.create(:api, share_user: share_user, main: true)
		end
	}
	before(:each) do
		visit new_share_user_api_path(user)
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
		find("#share_#{share.id}").click
		visit share_user_api_path(share_user, api)
	end
	
	it "should load in the character list partial", js: true do
		should have_selector('div#character_list')
		should have_selector('div.explanation')
		should have_selector('table#character_list_table')
	end

	describe " Set as Main > " do
		let!(:character1) {FactoryGirl.create(:character, api: api, share_id: share.id)}
		let!(:main_character) {FactoryGirl.create(:character, api: main_api, main: true, share_id: share.id)}
		it "each character should have a button to set that character as the main character", js: true do
			visit share_user_api_path(user, api)
			within "tr#character_id_#{character1.id}" do
				should have_selector("button#set_main_#{character1.id}")
			end
		end

		it "the main character should not have a button to set it as a main character", js: true do
			visit share_user_api_path(user, main_api)
			within "tr#character_id_#{main_character.id}" do
				should_not have_selector("button#set_main_#{main_character.id}")
			end
		end

		it "the main character should be marked as such", js: true do
			visit share_user_api_path(user, main_api)
			should have_selector("tr#character_id_#{main_character.id}", text: "Main Character")
		end

		it "clicking the main character button should redirect to the share user's api index", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				visit share_user_api_path(user, api)
				#http://stackoverflow.com/a/2609244
				page.evaluate_script('window.confirm = function() { return true; }')
				find("#set_main_#{character1.id}").click
				should have_selector('h3', text: "Your APIs")
			end
		end

		it "clicking the main character button should set that character as main", js: true do
			visit share_user_api_path(user, api)
			#http://stackoverflow.com/a/2609244
			page.evaluate_script('window.confirm = function() { return true; }')

			find("#set_main_#{character1.id}").click
			Character.find(character1.id).main.should be true
		end
	end

	describe " Delete API > " do
		it "should have a delete button", js: true do
			should have_selector("#show_destroy_api_#{api.id}", text: "Delete API")
		end

		it "should not have a delete button if it is a main api", js: true do
			visit share_user_api_path(user, main_api)
			should_not have_selector("#show_destroy_api_#{main_api.id}")
		end

		it "should redirect the user to the index page after deleting an API", js: true do
			#http://stackoverflow.com/a/2609244
			page.evaluate_script('window.confirm = function() { return true; }')

			click_link "Delete API"
			should have_selector("table#api_list_table")
		end
	end
end
