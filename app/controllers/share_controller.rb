class ShareController < ApplicationController
    before_action :authenticate_user!, only: [:create, :destroy, :index, :show]

    def new
    end

    def name_available
        name = Share.where("name = ?", params[:share_name])[0]
        if name.nil? == true
            render :json => true
        else
            render :json => false
        end
    end

    def create
        @new_share = Share.new(name: params[:share_name], grade: 2, owner_id: current_user.id, user_limit: 50)
        if @new_share.valid? == true
            @new_share.save!
            render :json => @new_share.id
        else
            render :json => false
        end
    end

    def destroy
    end

    def index
        @user_shares = current_user.shares
    end

    def show
        @share = Share.where("id = ?", params[:id])[0]
    end
end
