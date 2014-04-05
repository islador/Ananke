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

	#it "should be the proper page" do
	#	should have_selector('h1', text: "Api#new")
	#end

	it "should contain a link to generate a prefab key from" do
		should have_selector('a#user_prefab_key')
	end

	it "should render a form to enroll an API with" do
		should have_selector('input#key_id')
		should have_selector('input#v_code')
		should have_selector('input#main_api')
		should have_selector('button#enroll_new_api', text: 'Enroll Key')
	end
end
