class AddJoinLinkColumnToSharesTable < ActiveRecord::Migration
  def up
  	add_column :shares, :join_link, :string
  end
  def down
  	remove_column :shares, :join_link
  end
end
