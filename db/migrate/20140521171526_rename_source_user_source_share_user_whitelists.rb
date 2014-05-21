class RenameSourceUserSourceShareUserWhitelists < ActiveRecord::Migration
  def up
  	rename_column :whitelists, :source_user, :source_share_user
  end
  def down
  	rename_column :whitelists, :source_share_user, :source_user
  end
end
