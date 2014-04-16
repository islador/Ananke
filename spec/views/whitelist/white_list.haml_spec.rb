require 'spec_helper'

describe "whitelist/white_list.haml > " do
	subject {page}
	let!(:user) {FactoryGirl.create(:user)}

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

		describe "API Pull Table > " do
			let!(:api1) {FactoryGirl.create(:api, main_entity_name: "Avah", ananke_type: 1)}
			let!(:api2) {FactoryGirl.create(:api)}
			it "should render the white_list table" do
				should have_selector('#api_pulls_table')
			end

			it "should render datatables", js: true do
				should have_selector('#api_pulls_table_wrapper')
			end

			it "should contain items from the database" do
				visit whitelist_white_list_path
				within '#api_pulls_table' do
					should have_selector("tr#entity_#{api1.id}", text: api1.main_entity_name)
				end
			end

			
			it "should contain a cancel button for each API" do
				visit whitelist_white_list_path
				should have_selector("button#destroy_entity_#{api2.id}", text: "Cancel Pull")
			end

			describe "Cancel > " do
				let!(:api3) {FactoryGirl.create(:api, main_entity_name: "Avah", ananke_type: 1)}
				it "should remove the item from the datatable when clicked", js: true do
					visit whitelist_white_list_path
					
					should have_selector("tr#entity_#{api3.id}", text: api3.main_entity_name)
					
					#http://stackoverflow.com/a/2609244
					page.evaluate_script('window.confirm = function() { return true; }')

					click_button 'Cancel'
					should_not have_selector("tr#entity_#{api3.id}", text: api3.main_entity_name)
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
		let!(:whitelist3) {FactoryGirl.create(:whitelist, name: "Jeff")}
		it "should remove the item from the datatable when clicked", js: true do
			visit whitelist_white_list_path
			
			should have_selector("tr#entity_#{whitelist3.id}", text: whitelist3.name)
			
			#http://stackoverflow.com/a/2609244
			page.evaluate_script('window.confirm = function() { return true; }')

			click_button 'Delete'
			should_not have_selector("tr#entity_#{whitelist3.id}", text: whitelist3.name)
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
