class CreateApis < ActiveRecord::Migration
  def change
    create_table :apis do |t|
      t.integer :user_id
      t.integer :entity
      t.string :key_id
      t.string :v_code
      t.integer :accessmask
      t.boolean :active

      t.timestamps
    end
  end
end
