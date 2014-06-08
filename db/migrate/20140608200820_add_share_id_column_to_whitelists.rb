class AddShareIdColumnToWhitelists < ActiveRecord::Migration
  def up
  	add_column :whitelists, :share_id, :integer
  	add_column :whitelist_logs, :share_id, :integer
  end
  def down
  	remove_column :whitelists, :share_id, :integer
  	remove_column :whitelist_logs, :share_id, :integer
  end
end
