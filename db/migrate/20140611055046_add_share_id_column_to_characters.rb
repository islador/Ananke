class AddShareIdColumnToCharacters < ActiveRecord::Migration
  def up
  	add_column :characters, :share_id, :integer
  end
  def down
  	remove_column :characters, :share_id, :integer
  end
end
