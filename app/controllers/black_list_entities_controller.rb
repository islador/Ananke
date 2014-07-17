class BlackListEntitiesController < ApplicationController
    before_action :authenticate_user!, :require_share_user

    def create
    end

    def destroy
    end

    def index
    end

    def show
    end

    def logs
        csu = current_share_user
        @bll = BlackListEntityLog.where("share_id = ?", csu.share_id)

        @source_share_user_names = {}

        values = BlackListEntityLog.where("share_id =?", csu.share_id).pluck("source_share_user_id").uniq
        names = ShareUser.where(id: values).pluck("main_char_name")
        values.each do |val|
            @source_share_user_names.store(names[values.index(val)].to_sym, val)
        end

    end

    def retrieve_pullable_apis
    end
end
