class RenameSourceUserSourShareUserWhitelistLogs < ActiveRecord::Migration
  def up
  	rename_column :whitelist_logs, :source_user, :source_share_user
  end
  def down
  	rename_column :whitelist_logs, :source_share_user, :source_user
  end
end
