class AddMinAndMaxServiceRegisterImportValuesToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :max_ars_credit_dif, :float, default: -25.0
    add_column :settings, :max_usd_credit_dif, :float, default: -2.5
  end
end
