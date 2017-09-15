class AddOperatorAptourIdToServiceRegister < ActiveRecord::Migration
  def change
    add_column :service_registers, :operator_aptour_id, :integer
    add_index :service_registers, :operator_aptour_id
  end
end
