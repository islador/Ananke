class RenameCharacterCharacterIdColumn < ActiveRecord::Migration
  def up
  	rename_column :characters, :characterID, :character_id
  end
  def down
  	rename_column :characers, :character_id, :characterID
  end
end
