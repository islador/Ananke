class CreateWhitelists < ActiveRecord::Migration
  def change
    create_table :whitelists do |t|
      t.string :name
      t.integer :standing
      t.integer :type
      t.integer :source
      t.integer :source_user

      t.timestamps
    end
  end
end
