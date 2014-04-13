class AddNameColumnToApis < ActiveRecord::Migration
  def up
  	add_column :apis, :name, :string
  end
  def down
  	remove_column :apis, :name, :string
  end
end
