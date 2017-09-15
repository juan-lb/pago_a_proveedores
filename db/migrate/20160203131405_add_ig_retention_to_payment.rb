class AddIgRetentionToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :ig_retention_in_cents, :integer, limit: 8, default: 0
  end
end
