class ChangeColumnTimeWhitelistLog < ActiveRecord::Migration
  def up
  	remove_column :whitelist_logs, :time
  	add_column :whitelist_logs, :time, :datetime
  end

  def down
  	add_column :whitelist_logs, :time
  	remove_column :whitelist_logs, :time, :datetime
  end
end
