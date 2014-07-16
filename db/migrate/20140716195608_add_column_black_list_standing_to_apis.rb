class AddColumnBlackListStandingToApis < ActiveRecord::Migration
  def up
  	add_column :apis, :black_list_standings, :integer
  end
  def down
  	remove_column :apis, :black_list_standings
  end
end
