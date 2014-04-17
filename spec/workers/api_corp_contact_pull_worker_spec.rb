require 'spec_helper'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

describe ApiCorpContactPullWorker do
	describe "Perform > "
		let!(:user) {FactoryGirl.create(:user)}
		let!(:corp_api) {FactoryGirl.create(:corp_api, user: user)}

		#This whole block is likely going to need to be duplicated in the whitelist controller and its spec.
		describe "Error Handling > "
			xit "should throw an argument error if the API is not active." do
			end

			xit "should throw an argument error if the API is not a corp API" do
			end
		end

		xit "Should query the corp contact list on the eve API" do
		end

		xit "Should check for any existing entities in the database belonging to the API" do
		end

		#Possibly need a 'whitelist standings' column on the api model for this.
		xit "Should remove existing entities that no longer match standings requirements." do
		end

		xit "should add new entities to the whitelist that match standings requirements" do
		end

		xit "should not remove entities that match standings requirements." do
		end

		xit "should generate a whitelist_log entry for itself" do
		end
	end
end