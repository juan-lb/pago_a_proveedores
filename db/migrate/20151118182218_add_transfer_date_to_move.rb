class AddTransferDateToMove < ActiveRecord::Migration
  def change
    add_column :moves, :transfer_date, :date
  end
end
