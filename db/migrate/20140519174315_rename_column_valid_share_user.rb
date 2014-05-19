class RenameColumnValidShareUser < ActiveRecord::Migration
  def up
  	rename_column :share_users, :valid, :approved
  end
  def down
  	rename_column :share_users, :approved, :valid
  end
end
