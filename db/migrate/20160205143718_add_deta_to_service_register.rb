class AddDetaToServiceRegister < ActiveRecord::Migration
  def change
    add_column :service_registers, :deta, :text
  end
end
