require 'spec_helper'

describe "api/new.html.haml > " do
	let!(:user) {FactoryGirl.create(:user)}

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
		should have_selector('div#character_partial')
	end

	describe "First API > " do
		it "should have the main api box checked by default" do
			find('input#main_api').should be_checked
			fill_in('key_id', :with => "123456789")
			fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
			click_button 'Enroll Key'
		end

		it "should uncheck the main api box after a successful enrollment", js: true do
			fill_in('key_id', :with => "123456789")
			fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
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
			fill_in('key_id', :with => "123456789")
			fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
			find(:css, "#main_api").set(true)
			click_button 'Enroll Key'

			#This test is not complete
		end
		it "after a main API is submitted, it should load in the character list partial", js: true do
			fill_in('key_id', :with => "123456789")
			fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
			find(:css, "#main_api").set(true)
			click_button 'Enroll Key'

			should have_selector('div#character_list')
		end

		describe "Character List Partial > " do
			it "should contain an explanation of terms" do
				fill_in('key_id', :with => "123456789")
				fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
				find(:css, "#main_api").set(true)
				click_button 'Enroll Key'

				should have_selector('.explanation')
			end

			describe "Character List Table > " do
				it "should render the character_list table" do
					fill_in('key_id', :with => "123456789")
					fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
					find(:css, "#main_api").set(true)
					click_button 'Enroll Key'

					should have_selector('#character_list_table')
				end

				it "should render datatables", js: true do
					fill_in('key_id', :with => "123456789")
					fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
					find(:css, "#main_api").set(true)
					click_button 'Enroll Key'

					should have_selector('#character_list_table_wrapper')
				end

				it "should contain the api's characters" do
					fill_in('key_id', :with => "123456789")
					fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
					find(:css, "#main_api").set(true)
					click_button 'Enroll Key'

					within '#character_list_table' do
						should have_selector("tr#character_id_#{character1.id}")
						should have_selector("tr#character_id_#{character2.id}")
						should have_selector("tr#character_id_#{character3.id}")
					end
				end

				it "should not contain other api's characters" do
					fill_in('key_id', :with => "123456789")
					fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
					find(:css, "#main_api").set(true)
					click_button 'Enroll Key'

					within '#character_list_table' do
						should_not have_selector("tr#character_id_#{character4.id}")
					end
				end

				it "if no characters are set as the main, it should contain a button to set a character as the main", js: true do
					fill_in('key_id', :with => "123456789")
					fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
					find(:css, "#main_api").set(true)
					click_button 'Enroll Key'

					should have_selector("button#set_main_#{character1.id}")
					should have_selector("button#set_main_#{character2.id}")
					should have_selector("button#set_main_#{character3.id}")
				end
			end
		end
	end

	describe "Create > " do
		it "should add the API to the database", js: true do
			fill_in('key_id', :with => "123456789")
			fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")

			find_field('key[id]').value.should eq '123456789'
			find_field('v[code]').value.should eq 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'

			expect{
				click_button 'Enroll Key'
			}.to change(Api, :count).by(+1)
		end

		it "should clear the v_code and key_id fields after creating an API", js: true do
			fill_in('key_id', :with => "1234789")
			fill_in('v_code', :with => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
			click_button 'Enroll Key'

			find_field('key[id]').value.should eq ''
			find_field('v[code]').value.should eq ''
		end
	end
end
