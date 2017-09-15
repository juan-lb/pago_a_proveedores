class AddFecOutToServiceRegister < ActiveRecord::Migration
  def change
    add_column :service_registers, :fec_out, :date
  end
end
