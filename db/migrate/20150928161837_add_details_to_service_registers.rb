class AddDetailsToServiceRegisters < ActiveRecord::Migration
  def change
    add_column :service_registers, :nombreagencia, :string
    add_column :service_registers, :viajeroresponsable, :string
  end
end
