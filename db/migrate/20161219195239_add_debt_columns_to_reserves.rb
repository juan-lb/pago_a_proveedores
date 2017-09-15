class AddDebtColumnsToReserves < ActiveRecord::Migration
  def change
    add_column :reserves, :debt_in_cents, :integer, limit: 8, default: 0
    add_column :reserves, :debt_usd_in_cents, :integer, limit: 8, default: 0
  end
end
