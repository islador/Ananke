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
        #Create a custom join link for the share
        @new_share.join_link = Base64.encode64("#{params[:share_name]}"+"#{Time.now}").chomp.reverse
        
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
        #Retrieves the current user's shares from the database, then sorts them alphabetically to ensure the names don't move around unexpectedly.
        @user_shares = current_user.shares.sort_by!{|a| a.name.downcase}
    end

    def show
        @share = Share.where("id = ?", params[:id])[0]
        #session[:share_id] = @share.id
        shareUser = ShareUser.where("share_id = ? AND user_id = ?", @share.id, current_user.id)[0]
        if shareUser.nil? == false
            session[:share_user_id] = shareUser.id
        end
    end

    def join
        #A user should be able to join a share by API
        #A user should be able to join a share by typing in the group's name
            #Group name should filter from Alliance, to Corporation, and return the first match
        #A user should be able to join a share by invite link <-optimal solution
    end
end
