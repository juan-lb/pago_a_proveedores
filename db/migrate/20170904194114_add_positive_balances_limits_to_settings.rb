class AddPositiveBalancesLimitsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :min_ars_credit_report, :float, default: 500
    add_column :settings, :min_usd_credit_report, :float, default: 50
  end
end
