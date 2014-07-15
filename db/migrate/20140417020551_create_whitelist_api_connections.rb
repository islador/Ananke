class CreateWhitelistApiConnections < ActiveRecord::Migration
  def change
    create_table :whitelist_api_connections do |t|
      t.integer :api_id
      t.integer :whitelist_id

      t.timestamps
    end
  end
end
