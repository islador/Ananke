#require_dependency '/home/islador/.rvm/gems/ruby-2.1.1@Ananke/bundler/gems/eve-6e340c255be1/lib/eve.rb'

class ContactListWorker
	include Sidekiq::Worker
	#include EVE

	def perform(keyID, vCode)
		#api = Eve::API.new()
		#We want this to hit the API and then hit the database directly. That means it will likely need to be controller fired, not API model fired.
		api = Eve::API.new(:key_id => keyID, :v_code => vCode)
		#puts "api instantiated"
		result = api.corporation.contact_list

		result.corporateContactList.each do |k|
		    puts k.contactName + " " + k.standing.to_s + " " + k.contactTypeID.to_s
		end
	end
end