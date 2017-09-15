class RenameReserveDataToReserve < ActiveRecord::Migration
  def change
    rename_table :reserves_data, :reserves
  end
end
