require 'spec_helper'

describe "whitelist/white_list.haml >" do
	subject {page}

	before(:each) do
		visit whitelist_white_list_path
	end

	describe "Table > " do
		it "should render the white_list table" do
			should have_selector('#whitelist_table')
		end

		it "should render datatables", js: true do
			should have_selector('#whitelist_table_wrapper')
		end

		let!(:whitelist) {FactoryGirl.create(:whitelist, name: "Jeff")}
		it "should contain items from the database" do
			visit whitelist_white_list_path
			within '#whitelist_table' do
				should have_selector("tr#entity_1", text: whitelist.name)
			end
		end
	end
end
