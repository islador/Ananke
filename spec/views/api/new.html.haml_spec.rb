require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe "api/new.html.haml > " do
	let!(:user) {FactoryGirl.create(:user)}
	Capybara.default_wait_time = 10

	subject {page}
	

	before(:each) do
		visit new_user_api_path(user)
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
		visit new_user_api_path(user)
	end

	it "should contain a link to generate a prefab key from" do
		should have_selector('a#user_prefab_key')
	end

	it "should render a form to enroll an API with" do
		should have_selector('input#key_id')
		should have_selector('input#v_code')
		should have_selector('input#main_api')
		should have_selector('button#enroll_new_api', text: 'Enroll Key')
	end

	it "should contain a div for the characters partial to load into" do
		should have_selector('div#characters_partial')
	end

	describe "First API > " do
		it "should have the main api box checked by default" do
			find('input#main_api').should be_checked
			fill_in('key_id', :with => "3255235")
			fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
			click_button 'Enroll Key'
		end

		it "should uncheck the main api box after a successful enrollment", js: true do
			fill_in('key_id', :with => "3255235")
			fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
			click_button 'Enroll Key'
			find('input#main_api').should_not be_checked
		end

		let!(:api) {FactoryGirl.create(:api, user: user)}
		it "should not have the main api box checked if it is not the user's first API" do
			visit new_user_api_path(user)
			find('input#main_api').should_not be_checked
		end
	end

	describe "Main API > " do
		it "after a main api is submitted, it should lock the screen for five seconds", js: true do
			fill_in('key_id', :with => "3255235")
			fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
			find(:css, "#main_api").set(true)
			click_button 'Enroll Key'

			should have_selector("div.modal-backdrop")
		end
		it "after a main API is submitted, it should load in the character list partial", js: true do
			fill_in('key_id', :with => "3255235")
			fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
			find(:css, "#main_api").set(true)
			click_button 'Enroll Key'

			should have_selector('div#character_list')
			should have_selector('div.explanation')
			should have_selector('table#character_list_table')
			#should have_selector("tr", text: "Tany Ishsar")
			#should have_selector("button", text: "Set as Main")
		end

		describe "Character List Partial > " do
			#it "should contain an explanation of terms" do
			#	fill_in('key_id', :with => "3255235")
			#	fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
			#	find(:css, "#main_api").set(true)
			#	click_button 'Enroll Key'

			#	should have_selector('div.explanation')
			#end

			describe "Character List Table > " do
				#it "should render the character_list table" do
				#	fill_in('key_id', :with => "3255235")
				#	fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				#	find(:css, "#main_api").set(true)
				#	click_button 'Enroll Key'

				#	should have_selector('table#character_list_table')
				#end

				#it "should render datatables", js: true do
				#	fill_in('key_id', :with => "3255235")
				#	fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				#	find(:css, "#main_api").set(true)
				#	click_button 'Enroll Key'

				#	should have_selector('#character_list_table_wrapper')
				#end

				#it "should contain the api's characters" do
				#	fill_in('key_id', :with => "3255235")
				#	fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				#	find(:css, "#main_api").set(true)
				#	click_button 'Enroll Key'

				#	within 'table#character_list_table' do
				#		should have_selector("tr", text: "Tany Ishsar")
						#should have_selector("tr#character_id_#{character2.id}")
						#should have_selector("tr#character_id_#{character3.id}")
				#	end
				#end

				#it "should not contain other api's characters" do
				#	fill_in('key_id', :with => "3255235")
				#	fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				#	find(:css, "#main_api").set(true)
				#	click_button 'Enroll Key'

				#	within 'table#character_list_table' do
				#		should_not have_selector("tr", text: "islador")
				#	end
				#end

				#it "if no characters are set as the main, it should contain a button to set a character as the main", js: true do
				#	fill_in('key_id', :with => "3255235")
				#	fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				#	find(:css, "#main_api").set(true)
				#	click_button 'Enroll Key'

				#	should have_selector("button", text: "Set as Main")
					#should have_selector("button", text: "Set as Main")
					#should have_selector("button", text: "Set as Main")
				#end
			end
		end
	end

	describe "Create > " do
		it "should add the API to the database", js: true do
			fill_in('key_id', :with => "3255235")
			fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")

			find_field('key[id]').value.should eq '3255235'
			find_field('v[code]').value.should eq 'P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x'

			count = Api.count

			click_button 'Enroll Key'
			sleep(6)
			Api.count.should be > count
		end

		it "should clear the v_code and key_id fields after creating an API", js: true do
			fill_in('key_id', :with => "3255235")
			fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
			click_button 'Enroll Key'

			find_field('key[id]').value.should eq ''
			find_field('v[code]').value.should eq ''
		end
	end
end
