class AddStatusServiceToServiceRegisters < ActiveRecord::Migration
  def change
    add_column :service_registers, :status_service, :integer
  end
end
