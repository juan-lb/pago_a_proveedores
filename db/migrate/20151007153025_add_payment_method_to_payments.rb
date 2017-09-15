class AddPaymentMethodToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_method, :integer
    add_column :payments, :payment_method_number, :string
  end
end
