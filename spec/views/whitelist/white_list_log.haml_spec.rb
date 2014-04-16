require 'spec_helper'

describe "whitelist/white_list_log.haml >" do
	subject {page}
	let!(:user) {FactoryGirl.create(:user)}


	before(:each) do
		visit whitelist_white_list_log_path
		fill_in('user_email', :with => user.email)
		fill_in('user_password', :with => user.password)
		click_button 'Sign in'
		visit whitelist_white_list_log_path
	end

	describe " Table > " do
		let!(:whitelistlog) {FactoryGirl.create(:whitelist_log, entity_name: "Jeff")}

		it "should render the white_list table" do
			should have_selector('#whitelist_log_table')
		end
		
		it "should render datatables", js: true do
			should have_selector('#whitelist_log_table_wrapper')
		end

		it "should contain items from the database", js: true do
			visit whitelist_white_list_log_path
			within '#whitelist_log_table' do
				should have_selector("tr#entity_#{WhitelistLog.last.id}", text: whitelistlog.entity_name)
			end
		end
	end
end
