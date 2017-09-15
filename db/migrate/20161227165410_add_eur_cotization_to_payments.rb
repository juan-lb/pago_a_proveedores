class AddEurCotizationToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :eur_cotization_in_cents, :integer, limit: 8
  end
end
