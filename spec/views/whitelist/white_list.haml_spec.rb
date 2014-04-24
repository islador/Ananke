require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe "whitelist/white_list.haml > " do
	subject {page}
	let!(:user) {FactoryGirl.create(:user)}
	let!(:whitelist) {FactoryGirl.create(:whitelist, source_user: user.id)}

	before(:each) do
		visit whitelist_white_list_path
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
		visit whitelist_white_list_path
	end

	describe "Moderation Panel > " do
		it "should render a form to manually add an entity" do
			should have_selector('input#entity_name')
			should have_selector('input#entity_type_1')
			should have_selector('input#entity_type_2')
			should have_selector('input#entity_type_3')
			should have_selector('input#entity_type_4')
			should have_selector('button#submit_new_entity', text: 'Add Entity')
		end

		describe "API based whitelist entity population > " do
			
			#let!(:user) {FactoryGirl.create(:user)}
			let!(:valid_api) {
				VCR.use_cassette('workers/api_key_info/corpAPI') do
					FactoryGirl.create(:corp_api, user: user, active: true)
				end
			}
			let!(:pulled_api) {
				VCR.use_cassette('workers/api_key_info/corpAPI') do
					FactoryGirl.create(:corp_api, user: user, active: true)
				end
			}
			let!(:whitelist) {FactoryGirl.create(:whitelist, source_user: user.id, source_type: 1)}
			let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: pulled_api.id, whitelist_id: whitelist.id)}
			it "should contain a button 'Begin New API Pull'" do
				should have_selector('button#begin_new_api_pull', text: "Begin New API Pull")
			end

			it "when 'Begin new API Pull' is clicked, it should hide the 'Begin New API Pull' button", js: true do
				click_button 'Begin New API Pull'
				should_not have_selector('button#begin_new_api_pull', text: "Begin New API Pull")
			end

			it "when 'Begin new API Pull' is clicked, it should have a 'Close API Pull Table' button", js: true do
				click_button 'Begin New API Pull'
				should have_selector('button#begin_new_api_pull', text: "Close API Pull Table")
			end

			it "when 'Close API Pull Table' button is clicked, it should hide the valid_api_table", js: true do
				click_button 'Begin New API Pull'
				click_button 'Close API Pull Table'
				should_not have_selector('#valid_api_table')
			end

			it "when 'Close API Pull Table' button is clicked, it should have a 'Begin new API Pull' button", js: true do
				click_button 'Begin New API Pull'
				click_button 'Close API Pull Table'
				should have_selector('button#begin_new_api_pull')
			end

			it "when 'Begin new API Pull' is clicked, it should render the 'new_whitelist_api_pull' partial", js: true do
				click_button 'Begin New API Pull'
				should have_selector('table#valid_api_table')
				should have_selector("tr#add_api_#{valid_api.id}")
				should have_selector("select#select_#{valid_api.id}")
				should have_selector("button#query_api_#{valid_api.id}")
				should_not have_selector("tr#add_api_#{pulled_api.id}")
				should have_selector("button#query_api_#{valid_api.id}")
				should have_selector("#valid_api_table_wrapper")
			end

			it "when 'Query API' is clicked it should remove the api from the table", js: true do
				click_button 'Begin New API Pull'
		        click_button 'Query API'
		        should_not have_selector("tr#add_api_#{valid_api.id}")
			end

			it "When 'Query API' is clicked, it should add the api to the api_pulls_table", js: true do
				click_button 'Begin New API Pull'
		        click_button 'Query API'
		        within '#api_pulls_table' do
					should have_selector("tr td", text: "You")
					should have_selector("tr td", text: valid_api.main_entity_name)
					should have_selector("tr td", text: "10")
					should have_selector("tr td", text: valid_api.key_id)
				end
			end
		end

		describe "API Pull Table > " do
			let!(:api1) {
				VCR.use_cassette('workers/api_key_info/corpAPI') do
					FactoryGirl.create(:corp_api, user: user)
				end
			}
			let!(:whitelist_api_connection) {FactoryGirl.create(:whitelist_api_connection, api_id: api1.id, whitelist_id: whitelist.id)}
			let!(:api2) {
				VCR.use_cassette('workers/api_key_info/characterAPI') do
					FactoryGirl.create(:api, user: user)
				end
			}
			it "should render the api pulls table" do
				should have_selector('#api_pulls_table')
			end

			it "should render datatables", js: true do
				should have_selector('#api_pulls_table_wrapper')
			end

			it "should contain items from the database" do
				visit whitelist_white_list_path
				within '#api_pulls_table' do
					should have_selector("tr#pull_api_#{api1.id}", text: api1.user.main_char_name)
				end
			end

			
			it "should contain a cancel button for each API" do
				visit whitelist_white_list_path
				should have_selector("button#cancel_pull_api_#{api1.id}", text: "Cancel Pull")
			end

			describe "Cancel > " do
				let!(:api3) {
					VCR.use_cassette('workers/api_key_info/characterAPI') do
						FactoryGirl.create(:api, main_entity_name: "Avah", ananke_type: 1)
					end
				}
				it "should remove the item from the datatable when clicked", js: true do
					visit whitelist_white_list_path
					
					should have_selector("tr#pull_api_#{api1.id}", text: api1.main_entity_name)
					
					#http://stackoverflow.com/a/2609244
					page.evaluate_script('window.confirm = function() { return true; }')

					click_button 'Cancel'
					should_not have_selector("tr#pull_api_#{api1.id}", text: api1.main_entity_name)
				end
			end
		end
	end

	describe "Table > " do
		it "should render the white_list table" do
			should have_selector('#whitelist_table')
		end

		it "should render datatables", js: true do
			should have_selector('#whitelist_table_wrapper')
		end

		let!(:whitelist1) {FactoryGirl.create(:whitelist, name: "Jeff")}
		it "should contain items from the database" do
			visit whitelist_white_list_path
			within '#whitelist_table' do
				should have_selector("tr#entity_#{whitelist1.id}", text: whitelist1.name)
			end
		end

		let!(:whitelist2) {FactoryGirl.create(:whitelist)}
		it "should contain a delete button for each entity" do
			visit whitelist_white_list_path
			should have_selector("button#destroy_entity_#{whitelist2.id}", text: "Delete")
		end
	end

	describe "Delete > " do
		#let!(:whitelist3) {FactoryGirl.create(:whitelist, name: "Jeff")}
		it "should remove the item from the datatable when clicked", js: true do
			visit whitelist_white_list_path
			
			should have_selector("tr#entity_#{whitelist.id}", text: whitelist.name)
			
			#http://stackoverflow.com/a/2609244
			page.evaluate_script('window.confirm = function() { return true; }')

			click_button 'Delete'
			should_not have_selector("tr#entity_#{whitelist.id}", text: whitelist.name)
		end
	end

	describe "Create > " do
		it "should add the item to the database", js: true do
			fill_in('entity_name', :with => "Jeff")
			expect{
				click_button 'Add Entity'
			}.to change(Whitelist, :count).by(+1)
		end

		it "should clear the entity_name field after creating an entity", js: true do
			fill_in('entity_name', :with => "Jeff")
			click_button 'Add Entity'
			find_field('entity[name]').value.should eq ''
		end

		it "should redraw the table with the new item", js: true do
			fill_in('entity_name', :with => "Jeff")
			choose 'Alliance'
			click_button 'Add Entity'

			#This test is sloppy, it should reference the table more specifically.
			should have_selector("td", text: "Jeff")
			should have_selector("td", text: "Alliance")
			should have_selector("td", text: "You")
			should have_selector("td", text: "Manual")
			should have_selector("td", text: "Freshly Added")
		end

		it "should add the correct item to the database (Alliance Entity)", js: true do
			fill_in('entity_name', :with => "Jeff")
			choose 'Alliance'
			click_button 'Add Entity'
			#Table refresh uses a stubbing method. TR ID's are not possible in this iteration.
			visit whitelist_white_list_path
			within "tr#entity_#{Whitelist.last.id}" do
				should have_selector("td", text: "Alliance")
			end
		end

		it "should add the correct item to the database (Corporation Entity)", js: true do
			fill_in('entity_name', :with => "Jeff")
			choose 'Corporation'
			click_button 'Add Entity'
			#Table refresh uses a stubbing method. TR ID's are not possible in this iteration.
			visit whitelist_white_list_path
			within "tr#entity_#{Whitelist.last.id}" do
				should have_selector("td", text: "Corporation")
			end
		end
		it "should add the correct item to the database (Faction Entity)", js: true do
			fill_in('entity_name', :with => "Jeff")
			choose 'Faction'
			click_button 'Add Entity'
			#Table refresh uses a stubbing method. TR ID's are not possible in this iteration.
			visit whitelist_white_list_path
			within "tr#entity_#{Whitelist.last.id}" do
				should have_selector("td", text: "Faction")
			end
		end
		it "should add the correct item to the database (Character Entity)", js: true do
			fill_in('entity_name', :with => "Jeff")
			choose 'Character'
			click_button 'Add Entity'
			#Table refresh uses a stubbing method. TR ID's are not possible in this iteration.
			visit whitelist_white_list_path
			within "tr#entity_#{Whitelist.last.id}" do
				should have_selector("td", text: "Character")
			end
		end
	end
end
