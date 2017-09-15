class AddOperatorAptourIdToPaymentGroup < ActiveRecord::Migration
  def change
    add_column :payment_groups, :operator_aptour_id, :integer
    add_index :payment_groups, :operator_aptour_id
  end
end
