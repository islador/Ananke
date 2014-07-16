class CreateBlackListEntities < ActiveRecord::Migration
  def change
    create_table :black_list_entities do |t|
      t.string :name
      t.integer :standing
      t.integer :entity_type
      t.integer :source_type
      t.integer :source_share_user_id
      t.integer :share_id

      t.timestamps
    end
  end
end
