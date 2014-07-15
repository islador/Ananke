class AddShareIdColumnToWhitelistApiConnections < ActiveRecord::Migration
  def up
  	add_column :whitelist_api_connections, :share_id, :integer
  end
  def down
  	remove_column :whitelist_api_connections, :share_id, :integer
  end
end
