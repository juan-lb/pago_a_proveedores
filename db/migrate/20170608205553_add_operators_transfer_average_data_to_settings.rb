class AddOperatorsTransferAverageDataToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :operators_average_days, :integer, default: 15
    add_column :settings, :operators_average_emails, :string, default: ['ariel.corti@aero.tur.ar'].to_yaml
  end
end
