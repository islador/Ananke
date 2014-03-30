class CreateWhitelistLogs < ActiveRecord::Migration
  def change
    create_table :whitelist_logs do |t|
      t.string :entity_name
      t.integer :source_user
      t.integer :source_type
      t.boolean :addition
      t.integer :entity_type
      t.date :date
      t.time :time

      t.timestamps
    end
  end
end
