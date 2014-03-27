class CreateCharacters < ActiveRecord::Migration
  def change
    create_table :characters do |t|
      t.integer :api_id
      t.string :name
      t.integer :characterID
      t.string :corporationName
      t.integer :corporationID
      t.string :allianceName
      t.integer :allianceID
      t.string :factionName
      t.integer :factionID

      t.timestamps
    end
  end
end
