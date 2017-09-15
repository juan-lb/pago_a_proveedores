class AddEurosDifferenceToPaymentGroupReport < ActiveRecord::Migration
  def change
    add_column :payment_group_reports, :euros_difference, :float
  end
end
