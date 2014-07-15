class AddMainColumnToCharacters < ActiveRecord::Migration
  def up
  	add_column :characters, :main, :boolean
  end
  def down
  	remove_column :characters, :main, :boolean
  end
end
