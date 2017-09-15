class AddFecInToServiceRegisters < ActiveRecord::Migration
  def change
    add_column :service_registers, :fec_in, :date
  end
end
