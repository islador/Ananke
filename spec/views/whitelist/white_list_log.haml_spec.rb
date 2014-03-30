require 'spec_helper'

describe "whitelist/white_list_log.haml >" do
  subject {page}

	before(:each) do
		visit whitelist_white_list_log_path
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
