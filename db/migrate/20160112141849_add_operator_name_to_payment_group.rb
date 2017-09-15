class AddOperatorNameToPaymentGroup < ActiveRecord::Migration
  def change
    add_column :payment_groups, :operator_name, :string
  end
end
