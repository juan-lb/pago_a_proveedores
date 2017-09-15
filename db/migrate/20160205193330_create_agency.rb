class CreateAgency < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :name
      t.integer :agency_id, index: true
      t.string :color
    end
  end
end
