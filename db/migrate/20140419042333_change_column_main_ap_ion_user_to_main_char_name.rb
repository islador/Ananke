class ChangeColumnMainApIonUserToMainCharName < ActiveRecord::Migration
  def up
  	rename_column :users, :main_api, :main_char_name
  	change_column :users, :main_char_name, :string
  end
  def down
  	rename_column :users, :main_char_name, :main_api
  	change_column :users, :main_api, :integer
  end
end
