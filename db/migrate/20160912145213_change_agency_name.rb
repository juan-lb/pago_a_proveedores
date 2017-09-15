class ChangeAgencyName < ActiveRecord::Migration
  def up
    rename_column :agencies, :agency_id, :aptour_id 
  end
  
  def down
    rename_column :agencies, :aptour_id, :agency_id 
  end
end
