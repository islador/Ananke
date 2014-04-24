namespace :scheduling do
  desc "Validate all main APIs"
  task query_main_apis: :environment do
  	#Retrieve all APIs where main == true
  	query_apis = Api.where("main = true")
  	#Hit each API via sidekiq and validate its main character against the whitelist.
  end

  desc "Validate all whitelist APIs"
  task query_whitelist_apis: :environment do
  	#Retrieve all APIs with active whitelist_api_connections and thus need to be queried.
  	query_apis = Api.joins(:whitelist_api_connections).uniq

  	#Queue an ApiCorpContactPullWorker job for each API that needs querying.
  	query_apis.each do |qa|
  		ApiCorpContactPullWorker.perform_async(qa.id)
  	end

    #In this fashion APIs that have no whitelist api connections are not queried, and thus canceling a pull requires merely deleting the connections.
  end
end
