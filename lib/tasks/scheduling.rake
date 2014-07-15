namespace :scheduling do
  #CCP requests that a rate limit of 30 queries a second be observed across all end points.
  # https://wiki.eveonline.com/en/wiki/EVE_API
  #None of the workers currently respect this, that should be sorted out somehow before going into production

  #Cache time on this endpoint is 5 minutes.
  #https://api.eveonline.com/account/ApiKeyInfo.xml.aspx?keyID=3499606&vCode=WoLOSbOHENaxsWL4DrHhr16Rhw2eDcyEMEn5pZddvFfG9BDqETtEWc6rSC2pGGjv
  #Run every hour, staggered with whitelist updates.
  desc "Update all shares' share_user's approval status"
  task query_main_apis: :environment do
    #Retrieve a list of all shares
  	shares = Shares.all
    shares.each do |share|
      puts "Updating share_users of share #{share.name}(#{share.id})"
      #ShareUserApprovalWorker retrieves each main API in the share, updates it's character affiliations
      ShareUserApprovalWorker.perform_async(share.id)
    end
  end

  #Cache time on these APIs is 15 minutes.
  #https://api.eveonline.com/corp/ContactList.xml.aspx?keyID=3229801&vCode=UyO6KSsDydLrZX7MwU048rqRiHwAexvLmSQgtiUbN0rIrVaUuGUZYmGuW2PkMSg1
  #Run every hour.
  desc "Update all shares' whitelist APIs"
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
