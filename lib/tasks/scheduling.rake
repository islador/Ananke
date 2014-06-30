namespace :scheduling do
  desc "Validate all main APIs"
  task query_main_apis: :environment do
  	#Retrieve all APIs where main == true
  	query_apis = Api.where("main = true")
  	#Hit each API via sidekiq and validate its main character against the whitelist.
  end

  #Cache time on these APIs is 15 minutes.
  #https://api.eveonline.com/corp/ContactList.xml.aspx?keyID=3229801&vCode=UyO6KSsDydLrZX7MwU048rqRiHwAexvLmSQgtiUbN0rIrVaUuGUZYmGuW2PkMSg1
  #Run every hour.
  desc "Validate all shares' whitelist APIs"
  task query_whitelist_apis: :environment do
  	#Retrieve a list of all shares.
    shares = Shares.all
    shares.each do |share|
      puts "Updating share #{share.name}(#{share.id})'s whitelist."
      #WhitelistUpdateWorker retrieves each unique API used for whitelists from the WhitelistApiConnections table. Thus canceling a pull, merely requires deleting that API's WACs.
      WhitelistUpdateWorker.perform_async(share.id)
    end
  end
end
