class RenameFakeToAdjustmentOnPaymentGroup < ActiveRecord::Migration
  def change
    rename_column :payment_groups, :fake, :adjustment
  end
end
