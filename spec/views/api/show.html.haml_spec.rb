require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe "api/show.html.haml" do
	let!(:user) {FactoryGirl.create(:user)}
	Capybara.default_wait_time = 10

	subject {page}

	let!(:api) {FactoryGirl.create(:api, user: user)}
	let!(:main_api) {FactoryGirl.create(:api, user: user, main: true)}
	before(:each) do
		visit new_user_api_path(user)
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
		visit user_api_path(user, api)
	end
	
	it "should load in the character list partial", js: true do
		should have_selector('div#character_list')
		should have_selector('div.explanation')
		should have_selector('table#character_list_table')
	end

	it "should have a delete button" do
		should have_selector("button#destroy_api_#{api.id}")
	end

	it "should not have a delete button if it is a main api" do
		visit user_api_path(user, main_api)
		should_not have_selector("button#destroy_api_#{main_api.id}")
	end

	describe " Set as Main > " do
		let!(:character1) {FactoryGirl.create(:character, api: api)}
		let!(:main_character) {FactoryGirl.create(:character, api: main_api, main: true)}
		it "each character should have a button to set that character as the main character" do
			visit user_api_path(user, api)
			within "tr#character_id_#{character1.id}" do
				should have_selector("button#set_main_#{character1.id}")
			end
		end

		it "the main character should not have a button to set it as a main character" do
			visit user_api_path(user, main_api)
			within "tr#character_id_#{main_character.id}" do
				should_not have_selector("button#set_main_#{main_character.id}")
			end
		end

		it "the main character should be marked as such" do
			visit user_api_path(user, main_api)
			#within "tr#character_id_#{main_character.id}" do
				should have_selector("tr#character_id_#{main_character.id}", text: "Main Character")
			#end
		end
	end
end
