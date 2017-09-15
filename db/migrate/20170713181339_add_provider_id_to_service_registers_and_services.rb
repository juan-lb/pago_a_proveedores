class AddProviderIdToServiceRegistersAndServices < ActiveRecord::Migration
  def change
    add_column :service_registers, :provider_aptour_id, :integer
    add_column :services, :provider_aptour_id, :integer
  end
end
