class AddTransferDateToTransfer < ActiveRecord::Migration
  def change
    add_column :transfers, :transfer_date, :date
  end
end
