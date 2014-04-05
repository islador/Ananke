class ApiController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    current_user.apis.create(key_id: params[:key_id], v_code: params[:v_code])
    render nothing: true
  end

  def destroy
    Api.where("id = ?", params[:id])[0].destroy
    render nothing: true
  end

  def index
  end

  def show
  end
end
