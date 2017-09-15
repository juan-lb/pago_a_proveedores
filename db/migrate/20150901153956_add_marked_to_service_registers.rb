class AddMarkedToServiceRegisters < ActiveRecord::Migration
  def change
    add_column :service_registers, :marked, :boolean, default: false
  end
end
