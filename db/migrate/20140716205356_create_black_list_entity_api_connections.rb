class CreateBlackListEntityApiConnections < ActiveRecord::Migration
  def change
    create_table :black_list_entity_api_connections do |t|
      t.integer :api_id
      t.integer :black_list_entity_id
      t.integer :share_id

      t.timestamps
    end
  end
end
