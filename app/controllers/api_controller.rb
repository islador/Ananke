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

    #respond_to do |format|
    #  format.json render(:partial => '/shared/character_list', locals:{cl: @cl})
    #end
    respond_to do |format|
      format.js
    end
    
    #render json:

    #$('#team_1_display_table').empty().append("<%= escape_javascript(render(:partial => 'team_1_table', locals: {players: @players})) %>");
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
      end
      old_api.main = false
      old_character.save!
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

    render nothing: true
  end
end
