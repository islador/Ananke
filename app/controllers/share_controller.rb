class ShareController < ApplicationController
    before_action :authenticate_user!, only: [:create, :destroy, :index, :show, :join]

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
            @new_share.save

            render :json => [@new_share.join_link]
        else
            render :json => [false]
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
    end

    def join
        #A user should be able to join a share by invite link <-optimal solution
        @share = Share.where("join_link = ?", params[:join_id])[0]
        if @share.nil? == false
            if current_share_user(@share.id).nil? == false
                redirect_to share_path(@share.id)
            else
                @share_user = @share.share_users.new(user_id: current_user.id, user_role: 0, approved: false)
                if @share_user.valid? == true
                    @share_user.save
                    redirect_to new_share_user_api_path(share_user_id: @share_user.id)
                end
            end
        else
            render nothing: true, status: 404
        end
        
    end
end
