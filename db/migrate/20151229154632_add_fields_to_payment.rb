class AddFieldsToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :commission_in_cents, :integer, limit: 8, default: 0
    add_column :payments, :iva_in_cents, :integer, limit: 8, default: 0
    add_column :payments, :iibb_perception_in_cents, :integer, limit: 8, default: 0
    add_column :payments, :iva_perception_in_cents, :integer, limit: 8, default: 0
  end
end
