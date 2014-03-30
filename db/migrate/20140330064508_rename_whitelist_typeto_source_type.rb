class RenameWhitelistTypetoSourceType < ActiveRecord::Migration
  def up
  	rename_column :whitelists, :type, :entity_type
  	rename_column :whitelists, :source, :source_type
  end

  def down
  	rename_column :whitelists, :entity_type, :type
  	rename_column :whitelists, :source_type, :source
  end
end
