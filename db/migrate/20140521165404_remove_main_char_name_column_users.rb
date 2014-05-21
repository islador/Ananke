class RemoveMainCharNameColumnUsers < ActiveRecord::Migration
  def up
  	remove_column :users, :main_char_name
  end
  def down
  	add_column :users, :main_char_name, :string
  end
end
