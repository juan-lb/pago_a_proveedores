class AddTransferAverageUsdLimitToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :transfer_average_usd_limit, :float, default: 3000
  end
end
