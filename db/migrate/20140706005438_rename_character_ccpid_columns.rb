class RenameCharacterCcpidColumns < ActiveRecord::Migration
  def up
  	rename_column :characters, :character_id, :ccp_character_id
  	rename_column :characters, :corporationID, :ccp_corporation_id
  	rename_column :characters, :allianceID, :ccp_alliance_id
  	rename_column :characters, :factionID, :ccp_faction_id
  end
  def down
  	rename_column :characters, :ccp_character_id, :character_id
  	rename_column :characters, :ccp_corporation_id, :corporationID
  	rename_column :characters, :ccp_alliance_id, :allianceID
  	rename_column :characters, :ccp_faction_id, :factionID
  end
end
