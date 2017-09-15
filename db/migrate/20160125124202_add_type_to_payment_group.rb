class AddTypeToPaymentGroup < ActiveRecord::Migration
  def change
    add_column :payment_groups, :type, :string, null: false
  end
end
