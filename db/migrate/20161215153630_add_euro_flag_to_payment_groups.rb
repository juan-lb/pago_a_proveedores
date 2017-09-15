class AddEuroFlagToPaymentGroups < ActiveRecord::Migration
  def change
    add_column :payment_groups, :in_euros, :boolean, default: false
  end
end
