class ApiController < ApplicationController
  before_action :authenticate_user!

  def new
    @count = current_user.apis.count
  end

  def create
    api = current_user.apis.build(key_id: params[:key_id], v_code: params[:v_code])
    api.save!
    render :json => api.id
  end

  def destroy
    api = Api.where("id = ?", params[:id])[0]
    if api.nil? == false
      if api.main.nil? == true || api.main == false
        api.destroy!
      end
    end
    render nothing: true
  end

  def index
    @apis = current_user.apis
  end

  def show
    @api = Api.where("id = ?", params[:id])[0]
    @cl = @api.characters
  end

  def character_list
    @api = Api.where("id = ?", params[:api_id])[0]
    @cl = @api.characters

    respond_to do |format|
      format.js
    end
  end

  def set_main
    #Point of possible optimization
    #Retrieve the old API and set it's main to false
    old_api = current_user.apis.where("main = true")[0]
    #Nil check first to avoid empty on nil error
    if old_api.nil? == false
      old_character = old_api.characters.where("main = true")[0]
      if old_character.nil? == false
        old_character.main = false
        old_character.save!
      end
      old_api.main = false
      old_api.save!
    end
    

    #Retrieve the new API and set it's main to true

    @api = Api.where("id = ?", params[:api_id])[0]
    @character = Character.where("id = ?", params[:character_id])[0]

    @character.main = true
    if @character.valid? == true
      @character.save!
    end

    @api.main = true
    if @api.valid? == true
      @api.save!
    end

    #Point of optimization. This method could take the Api model already had, do its thing, then save it. Thus avoiding a DB access.
    @api.set_main_entity_name

    current_user.set_main_char_name(@character)
    render nothing: true
  end

  def begin_whitelist_api_pull
    api = Api.where("id = ?", params[:api_id])[0]
    if api.nil? == false
      ApiCorpContactPullWorker.perform_async(api.id)
      render :json => "API queued for contact processing"
    else
      render :json => "Invalid API"
    end
  end

  def cancel_whitelist_api_pull
    api = Api.where("id = ?", params[:api_id])[0]
    whitelist_connections = WhitelistApiConnection.where("api_id = ?", params[:api_id])
    #Determine if the API is valid and has an active pull
    if api.nil? == false && whitelist_connections.count > 0
      #Generate a whitelist log for the cancellation
      WhitelistLog.create(entity_name: api.main_entity_name, source_user: api.user.id, source_type: 2, addition: false, entity_type: 5, date: Date.today, time: Time.now)

      #Destroy all whitelist connections associated with the given api. 
      #Point of optimization - This can easily move to 100+ms and should likely be pushed to a sidekiq worker.
      whitelist_connections.each do |wc|
        wc.destroy
      end
      render :json => "API removed from contact processing"
    else
      render :json => "Invalid API or API is not a pulling API"
    end
  end

  def update_api_whitelist_standing
    api = Api.where("id = ?", params[:api_id])[0]

    if api.ananke_type != 1
      render :text => "API must be a corporation API"
      raise ArgumentError, "Api must be a corporation API."
    end

    if api.active != true
      render :text => "API must be active"
      raise ArgumentError, "Api must be active."
    end

    api.whitelist_standings = params[:standing]
    if api.valid? == true
      api.save!
      render :json => true
    else
      render :json => api.errors.messages
    end
  end
end
