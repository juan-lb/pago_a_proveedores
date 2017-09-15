class ChangeReserveColumn < ActiveRecord::Migration
  def up
    rename_column :reserves, :agency_id, :agency_aptour_id 
  end
  
  def down
    rename_column :reserves, :agency_aptour_id, :agency_id 
  end
end
