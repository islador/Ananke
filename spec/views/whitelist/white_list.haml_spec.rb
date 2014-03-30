require 'spec_helper'

describe "whitelist/white_list.haml >" do
	subject {page}
	let!(:user) {FactoryGirl.create(:user)}

	before(:each) do
		visit whitelist_white_list_path
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
	end

	describe "Table > " do
		it "should render the white_list table" do
			should have_selector('#whitelist_table')
		end

		it "should render datatables", js: true do
			should have_selector('#whitelist_table_wrapper')
		end

		#May be order specific, unsure
		let!(:whitelist) {FactoryGirl.create(:whitelist, name: "Jeff")}
		it "should contain items from the database" do
			visit whitelist_white_list_path
			within '#whitelist_table' do
				should have_selector("tr#entity_1", text: whitelist.name)
			end
		end

		let!(:whitelist) {FactoryGirl.create(:whitelist)}
		it "should contain a delete button for each entity" do
			visit whitelist_white_list_path
			within 'tr#entity_1' do
				should have_selector("button#destroy_entity_#{whitelist.id}", text: "Delete")
			end
		end
	end
end
