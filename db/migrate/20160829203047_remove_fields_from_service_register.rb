class RemoveFieldsFromServiceRegister < ActiveRecord::Migration
  def change
    remove_column :service_registers, :cobradopes_in_cents
    remove_column :service_registers, :cobradodol_in_cents
    remove_column :service_registers, :pagadopes_in_cents
    remove_column :service_registers, :pagadodol_in_cents
    remove_column :service_registers, :adelantospes_in_cents
  end
end
