class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.string :name
      t.integer :owner_id
      t.boolean :active
      t.integer :user_limit
      t.integer :class

      t.timestamps
    end
  end
end
