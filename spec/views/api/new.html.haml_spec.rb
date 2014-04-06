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

	describe "Create > " do
		#This spec is failing and I have no idea why. It tests manually just fine.
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
