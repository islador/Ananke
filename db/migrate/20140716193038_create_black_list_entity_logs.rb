class CreateBlackListEntityLogs < ActiveRecord::Migration
  def change
    create_table :black_list_entity_logs do |t|
      t.string :entity_name
      t.integer :source_share_user_id
      t.integer :source_type
      t.boolean :addition
      t.integer :entity_type
      t.date :date
      t.datetime :time
      t.integer :share_id

      t.timestamps
    end
  end
end
