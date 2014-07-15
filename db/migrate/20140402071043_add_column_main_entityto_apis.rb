class AddColumnMainEntitytoApis < ActiveRecord::Migration
  def up
  	add_column :apis, :main_entity, :string
  end
  def down
  	remove_column :apis, :main_entity, :string
  end
end
