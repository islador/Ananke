class RenameUserIdColumnApis < ActiveRecord::Migration
  def up
  	rename_column :apis, :user_id, :share_user_id
  end
  def down
  	rename_column :apis, :share_user_id, :user_id
  end
end
