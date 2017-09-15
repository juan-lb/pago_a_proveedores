class AddAgencyToReserveData < ActiveRecord::Migration
  def change
    add_reference :reserves_data, :agency,  index: true
  end
end
