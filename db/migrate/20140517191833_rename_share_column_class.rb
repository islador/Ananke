class RenameShareColumnClass < ActiveRecord::Migration
  def up
  	rename_column :shares, :class, :grade
  end
  def down
  	rename_column :shares, :grade, :class
  end
end
