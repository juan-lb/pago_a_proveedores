class AddCreditToTransfer < ActiveRecord::Migration
  def change
    add_column :transfers, :credit, :boolean
  end
end
