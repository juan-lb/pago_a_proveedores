class AddCotizationAndTotalDebtToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :cotization_in_cents, :integer, limit: 8
    add_column :payments, :total_debt_in_cents, :integer, limit: 8
  end
end
