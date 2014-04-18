class AddWhiteListStandingsColumntoApis < ActiveRecord::Migration
  def up
  	add_column :apis, :whitelist_standings, :integer
  end
  def down
  	remove_column :apis, :whitelist_standings, :integer
  end
end
