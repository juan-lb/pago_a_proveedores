class RemoveDifColumnsFromServiceRegister < ActiveRecord::Migration
  def change
    remove_column :service_registers, :difpes_in_cents
    remove_column :service_registers, :difdol_in_cents
  end
end
