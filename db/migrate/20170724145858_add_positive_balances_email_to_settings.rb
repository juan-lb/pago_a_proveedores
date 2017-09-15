class AddPositiveBalancesEmailToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :positive_balances_emails, :string, default: ['ariel.corti@aero.tur.ar'].to_yaml
  end
end
