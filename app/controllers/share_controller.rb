class ShareController < ApplicationController
    before_action :authenticate_user!

    def new
    end

    def name_available
        name = Share.where("name = ?", params[:name])[0]
        if name.nil? == true
            render :json => true
        else
            render :json => false
        end
    end

    def create
    end

    def destroy
    end

    def index
        @user_shares = current_user.shares
    end

    def show
    end
end