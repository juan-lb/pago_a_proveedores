class AddCategoryToPaymentGroup < ActiveRecord::Migration
  def change
    add_column :payment_groups, :category, :integer
  end
end
