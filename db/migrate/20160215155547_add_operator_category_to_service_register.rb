class AddOperatorCategoryToServiceRegister < ActiveRecord::Migration
  def change
    add_column :service_registers, :operator_category, :string, null: false #1=Nat, 2=Inter, 3=Aereo
  end
end
