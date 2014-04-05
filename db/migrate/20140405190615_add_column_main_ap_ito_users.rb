class AddColumnMainApItoUsers < ActiveRecord::Migration
  def up
  	add_column :users, :main_api, :integer
  end
  def down
  	remove_column :users, :main_api, :integer
  end
end
