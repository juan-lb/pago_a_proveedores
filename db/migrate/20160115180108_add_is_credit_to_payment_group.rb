class AddIsCreditToPaymentGroup < ActiveRecord::Migration
  def change
    add_column :payment_groups, :is_credit, :boolean, default: false
  end
end
