class ChangingColumnsInApi < ActiveRecord::Migration
	# Updating the API model to better reflect CCP vs Ananke Types
	def up
		rename_column :apis, :entity, :ccp_type
		add_column :apis, :ananke_type, :integer
		add_column :apis, :main, :boolean
		rename_column :apis, :main_entity, :main_entity_name
	end
	def down
		rename_column :apis, :ccp_type, :entity
		remove_column :apis, :ananke_type, :integer
		remove_column :apis, :main, :boolean
		rename_column :apis, :main_entity_name, :main_entity
	end
end
