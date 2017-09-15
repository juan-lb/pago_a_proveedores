class AddFecApeToReserve < ActiveRecord::Migration
  def change
    add_column :reserves, :fec_ape, :date
  end
end
