require 'spec_helper'

describe "share/index.html.haml" do
	let!(:user) {FactoryGirl.create(:user)}

	subject {page}

	describe "indexBox > " do
		describe "When Member > " do
			let!(:share) {FactoryGirl.create(:share, name: "MemberShare")}
			let!(:share_user) {FactoryGirl.create(:share_user, user_id: user.id, share_id: share.id)}
			
			before(:each) do
				visit share_index_path
				fill_in('user_email', :with => user.email)
				fill_in('user_password', :with => user.password)
				click_button 'Sign in'
			end
			
			it "should contain an indexBox with that share's ID" do
				should have_selector(".indexBox#share_#{share.id}")
			end

			it "should contain a shareName with that share's name" do
				should have_selector(".shareName", text: share.name)
			end

			it "should contain a shareLogo with that share's group logo" do
				should have_selector(".shareLogo")
			end

			describe "Click indexBox > " do
				it "clicking an indexBox should take you to that share's show page", js: true do
					page.evaluate_script("document.getElementById('share_#{share.id}').click()")
					should have_selector("h1", text: "#{share.name}")
				end
			end
		end

		describe "When Not a Member > " do
			let!(:share) {FactoryGirl.create(:share)}

			before(:each) do
				visit share_index_path
				fill_in('user_email', :with => user.email)
				fill_in('user_password', :with => user.password)
				click_button 'Sign in'
			end

			it "should contain a centered indexBox" do
				should have_selector(".indexBox .joinGroup")
				should_not have_selector(".col-md-4 .indexBox .joinGroup")
			end
		end
	end
end
