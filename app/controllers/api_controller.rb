class ApiController < ApplicationController
  before_action :authenticate_user!, :require_share_user

  def new
    @count = current_share_user.apis.count
  end

  def create
    api = current_share_user.apis.build(key_id: params[:key_id], v_code: params[:v_code])
    api.save!
    render :json => api.id
  end

  def destroy
    api = Api.where("id = ?", params[:id])[0]
    if api.nil? == false
      if api.main.nil? == true || api.main == false
        api.destroy
      end
    end
    render nothing: true
  end

  def index
    @apis = current_share_user.apis
  end

  def show
    @api = Api.where("id = ?", params[:id])[0]
    @cl = @api.characters
  end

  def character_list
    @api = Api.where("id = ?", params[:api_id])[0]
    @cl = @api.characters

    if @api.ananke_type == 1
      render :json => false
    else
      respond_to do |format|
        format.js
      end
    end
  end

  def set_main
    #Retrieve the new API
    @api = Api.where("id = ?", params[:api_id])[0]
    share_user = current_share_user
    if @api.ananke_type !=1 && @api.active == true
      #Point of possible optimization
      #Retrieve the old API and set it's main to false
      old_api = share_user.apis.where("main = true")[0]
      #Nil check first to avoid empty on nil error
      if old_api.nil? == false
        old_character = old_api.characters.where("main = true")[0]
        if old_character.nil? == false
          old_character.main = false
          old_character.save!
        end
        old_api.main = false
        old_api.save
      end

      #Set it's main to true
      @character = Character.where("id = ?", params[:character_id])[0]

      @character.main = true
      if @character.valid? == true
        if @character.approve_character? == true
          share_user.approved = true
        else
          share_user.approved = false
        end
        @character.save
      end

      @api.main = true
      if @api.valid? == true
        @api.main_entity_name = @character.name
        @api.save
      end

      share_user.main_char_name = @character.name

      if share_user.valid? == false && share_user.errors.messages[:share_users].nil? == false
        #Queue an email to the share owner/admins explaining who's just joined, but couldn't be approved, and why.
        render :json => share_user.errors.messages[:share_users]
        share_user.approved = false
        share_user.save
      else
        share_user.save
        render :json => [true]
      end
    else
      render :json => ["Something broke, why not try again?"], status: 400
    end
    
  end

  def begin_whitelist_api_pull
    api = Api.where("id = ?", params[:api_id])[0]
    if api.nil? == false && api.active == true && api.ananke_type == 1
      ApiCorpContactPullWorker.perform_async(api.id)
      render nothing: true, status: 200
      #render :json => "API queued for contact processing"
    else
      render nothing: true, status: 304
      #render :json => "Invalid API"
    end
  end

  def cancel_whitelist_api_pull
    api = Api.where("id = ?", params[:api_id])[0]
    whitelist_connections = WhitelistApiConnection.where("api_id = ?", params[:api_id])
    #Determine if the API is valid and has an active pull
    if api.nil? == false && whitelist_connections.count > 0
      #Generate a whitelist log for the cancellation
      WhitelistLog.create(entity_name: api.main_entity_name, source_share_user: api.share_user.id, source_type: 2, addition: false, entity_type: 5, date: Date.today, time: Time.now, share_id: api.share_user.share_id)

      #Destroy all whitelist connections associated with the given api. 
      #Point of optimization - This can easily move to 100+ms and should likely be pushed to a sidekiq worker.
      whitelist_connections.each do |wc|
        wc.destroy
      end
      render nothing: true
      #render :json => "API removed from contact processing"
    else
      render nothing: true, status: 400
      #render :json => "Invalid API or API is not a pulling API"
    end
  end

  def update_api_whitelist_standing
    api = Api.where("id = ?", params[:api_id])[0]

    if api.ananke_type != 1
      render nothing: true, status: 304
      #render :text => "API must be a corporation API"
      raise ArgumentError, "Api must be a corporation API."
    end

    if api.active != true
      render nothing: true, status: 304
      #render :text => "API must be active"
      raise ArgumentError, "Api must be active."
    end

    api.whitelist_standings = params[:standing]
    if api.valid? == true
      api.save!
      render nothing: true, status: 200
      #render :json => true
    else
      #Untested behavior. Should be fixed, but is out of scope for the current project.
      render :json => api.errors.messages, status: 406
    end
  end

  def begin_black_list_api_pull
    api = Api.where("id = ?", params[:api_id])[0]
    if api.nil? == false
      if api.ananke_type != 1
        render :json => ["Api must be a corp API"], status: 400
        raise ArgumentError, "Api must be a corporation API."
      end

      if api.active != true
        render :json => ["Api must be active."], status: 400
        raise ArgumentError, "Api must be active."
      end

      if api.active == true && api.ananke_type == 1
        #BlackListCorpContactPullWorker.perform_async(api.id)
        render :json => ["Populating Black List using API #{api.name}. All contacts with standing #{api.black_list_standings} and down will be black listed."], status: 200
      end
    end
  end

  def update_api_black_list_standings
    api = Api.where("id = ?", params[:api_id])[0]
    if api.ananke_type != 1
      render :json => ["Api must be a corp API"], status: 400
      raise ArgumentError, "Api must be a corporation API."
    end

    if api.active != true
      render :json => ["Api must be active."], status: 400
      raise ArgumentError, "Api must be active."
    end
    api.black_list_standings = params[:standing]
    if api.valid? == true
      render :json => ["Api Black List Standing set to: #{params[:standing]}"], status: 200
      api.save
    else
      render :json => [api.errors.messages], status: 406
    end
  end

  def cancel_black_list_api_pull
    api = Api.where("id = ?", params[:api_id])[0]
    #Ensure an API exists
    if api.nil? == false
      #Ensure the API is a corp API
      if api.ananke_type != 1
        render :json => ["Api must be a corp API"], status: 400 and return
      end

      #Ensure the API is active
      if api.active != true
        render :json => ["Api must be active."], status: 400 and return
      end

      #Retrieve any existing connections
      black_list_entity_api_connections = BlackListEntityApiConnection.where("api_id = ?", params[:api_id])
      #Determine if the API has an active pull
      if black_list_entity_api_connections.count > 0
        share_user = api.share_user

        black_list_entity_api_connections.each do |bleac|
          bleac.destroy
        end

        #Generate a black_list_entity_log for the cancellation
        BlackListEntityLog.create(entity_name: api.main_entity_name, source_share_user_id: share_user.id, source_type: 2, addition: false, entity_type: 5, date: Date.today, time: Time.now, share_id: share_user.share_id)

        render :json => ["API Pull successfully cancelled."]
      else
        render :json => ["Api does not have an active black list pull"], status: 400
      end
    else
      render :json => ["Api could not be found"], status: 400
    end
  end
end
