require 'spec_helper'

describe "whitelist/white_list_log.haml >" do
	subject {page}
	let!(:user) {FactoryGirl.create(:user)}

	before(:each) do
		visit whitelist_white_list_log_path
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
	end

	describe " Table > " do
		it "should render the white_list table" do
			should have_selector('#whitelist_log_table')
		end
		
		it "should render datatables", js: true do
			should have_selector('#whitelist_log_table_wrapper')
		end

		let!(:whitelistlog) {FactoryGirl.create(:whitelist_log, entity_name: "Jeff")}
		it "should contain items from the database" do
			visit whitelist_white_list_log_path
			within '#whitelist_log_table' do
				should have_selector("tr#entity_1", text: whitelistlog.entity_name)
			end
		end
	end
end
