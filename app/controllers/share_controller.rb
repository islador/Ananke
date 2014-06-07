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
        @new_share = Share.new(name: params[:share_name], grade: 2, active: true, owner_id: current_user.id, user_limit: 50)
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
        #session[:share_id] = @share.id
        shareUser = ShareUser.where("share_id = ? AND user_id = ?", @share.id, current_user.id)[0]
        if shareUser.nil? == false
            session[:share_user_id] = shareUser.id
        end
    end
end
