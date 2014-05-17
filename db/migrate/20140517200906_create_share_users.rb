class CreateShareUsers < ActiveRecord::Migration
  def change
    create_table :share_users do |t|
      t.integer :share_id
      t.integer :user_id
      t.integer :user_role
      t.string :main_char_name

      t.timestamps
    end
  end
end
