class AddOpeWithCcToServiceRegister < ActiveRecord::Migration
  def change
    add_column :service_registers, :ope_with_cc, :boolean, default: false
  end
end
