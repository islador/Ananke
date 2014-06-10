require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe "api/new.html.haml > " do
	let(:user) {FactoryGirl.create(:user)}
	let(:share) {FactoryGirl.create(:share)}
	let!(:share_user) {FactoryGirl.create(:share_user, share_id: share.id, user_id: user.id)}
	Capybara.default_wait_time = 10

	subject {page}
	

	before(:each) do
		visit new_share_user_api_path(share_user)
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
		find("#share_#{share.id}").click
		visit new_share_user_api_path(share_user)
	end

	it "should contain a link to generate a prefab key from", js: true do
		should have_selector('a#user_prefab_key')
	end

	it "should render a form to enroll an API with", js: true do
		should have_selector('input#key_id')
		should have_selector('input#v_code')
		should have_selector('input#main_api')
		should have_selector('button#enroll_new_api', text: 'Enroll Key')
	end

	describe "First API > " do
		
		it "should have the main api box checked by default", js: true do
			find('input#main_api').should be_checked
		end

		it "should uncheck the main api box after a successful enrollment", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
			
				click_button 'Enroll Key'
				find('input#main_api').should_not be_checked
			end
		end

		let!(:api) {
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				FactoryGirl.create(:api, share_user: share_user)
			end
		}
		it "should not have the main api box checked if it is not the user's first API", js: true do
			visit new_share_user_api_path(share_user)
			find('input#main_api').should_not be_checked
		end

		it "should redirect to the share user's api index if a corp api is enrolled", js: true do
			VCR.use_cassette('workers/api_key_info/corpAPI') do
				fill_in('key_id', :with => "3229801")
				fill_in('v_code', :with => "UyO6KSsDydLrZX7MwU048rqRiHwAexvLmSQgtiUbN0rIrVaUuGUZYmGuW2PkMSg1")
			
				click_button 'Enroll Key'
				should have_selector("h3", text: 'Your APIs')
			end
		end
	end

	describe "Main API > " do
		it "after a main api is submitted, it should lock the screen for five seconds", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				find(:css, "#main_api").set(true)
			
				click_button 'Enroll Key'
				should have_selector("div.modal-backdrop")
			end
		end
		it "after a main API is submitted, it should load in the character list partial", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				find(:css, "#main_api").set(true)
			
				click_button 'Enroll Key'

				should have_selector('div#character_list')
				should have_selector('div.explanation')
				should have_selector('table#character_list_table')
			end
		end

		it "after a main API is submitted, it should load in the character list partial and allow users to immediately set a main character.", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				find(:css, "#main_api").set(true)
			
				click_button 'Enroll Key'

				should have_selector('div#character_list')
				should have_selector('div.explanation')
				should have_selector('table#character_list_table')

				should have_content('button', :text => "Set as Main")
			end
		end

		it "after a main API's main character is selected, it should redirect to the share user's api index", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				find(:css, "#main_api").set(true)
			
				click_button 'Enroll Key'

				should have_selector('div#character_list')
				should have_selector('div.explanation')
				should have_selector('table#character_list_table')

				#http://stackoverflow.com/a/2609244
				page.evaluate_script('window.confirm = function() { return true; }')
				click_button 'Set as Main'
				should have_selector('h3', text: "Your APIs")
			end
		end

		it "Clicking 'Set as Main' should set that character as the main character", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				find(:css, "#main_api").set(true)
			
				click_button 'Enroll Key'

				#http://stackoverflow.com/a/2609244
				page.evaluate_script('window.confirm = function() { return true; }')
				click_button 'Set as Main'
				Character.last.main.should be true
			end
		end
	end

	describe "Non Main API > " do
		it "after non-main api is enrolled, it should redirect to the share user's api index", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				find(:css, "#main_api").set(false)
			
				click_button 'Enroll Key'

				should have_selector('h3', text: "Your APIs")
			end
		end
	end

	describe "Create > " do
		it "should add the API to the database", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")

				find_field('key[id]').value.should eq '3255235'
				find_field('v[code]').value.should eq 'P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x'

				count = Api.count
			
				click_button 'Enroll Key'
				
				sleep(6)
				Api.count.should be > count
			end	
		end

		it "should clear the v_code and key_id fields after creating an API", js: true do
			VCR.use_cassette('workers/api_key_info/characterAPI') do
				fill_in('key_id', :with => "3255235")
				fill_in('v_code', :with => "P4IZDKR0BqaFVZdvy24QVnFmkmsNjcicEocwvTdpxtTz7YhF2tPNigeVhr3Y8l5x")
				click_button 'Enroll Key'
				find_field('key[id]').value.should eq ''
				find_field('v[code]').value.should eq ''
			end
		end
	end
end
