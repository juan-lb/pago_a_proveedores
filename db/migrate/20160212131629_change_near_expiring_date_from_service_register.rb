class ChangeNearExpiringDateFromServiceRegister < ActiveRecord::Migration
  def change
    change_column :service_registers, :near_expiring_date_type, :string
  end
end
