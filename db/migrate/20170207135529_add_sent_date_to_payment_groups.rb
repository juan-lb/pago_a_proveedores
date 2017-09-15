class AddSentDateToPaymentGroups < ActiveRecord::Migration
  def change
    add_column :payment_groups, :sent_date, :datetime
  end
end
