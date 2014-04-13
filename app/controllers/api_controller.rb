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
    Api.where("id = ?", params[:id])[0].destroy
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
end
