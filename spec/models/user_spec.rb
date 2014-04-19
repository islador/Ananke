# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  main_char_name         :string(255)
#

require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe User do
	let!(:user) {FactoryGirl.create(:user)}

	subject{user}

	it {should respond_to :main_char_name}

	describe "set_main_char_name" do
		
		let!(:corp_api) {
			VCR.use_cassette('workers/api_key_info/corpAPI') do
				FactoryGirl.create(:corp_api, user: user, main: true)
			end
		}
		let!(:corp_character) {FactoryGirl.create(:character, api: corp_api, main: true, corporationName: "Alaskan Fish")}

		it "should set the user's main_char_name to the main character of the API's name" do
			user.set_main_char_name(corp_character)

			userDB = User.where("id = ?", user.id)[0]
			userDB.should_not be_nil
			userDB.main_char_name.should match "#{corp_character.name}"
		end
	end
end
