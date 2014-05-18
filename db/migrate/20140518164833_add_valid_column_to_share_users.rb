class AddValidColumnToShareUsers < ActiveRecord::Migration
  def up
  	add_column :share_users, :valid, :boolean
  end
  def down
  	remove_column :share_users, :valid, :boolean
  end
end
