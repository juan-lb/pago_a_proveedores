class AddLastEmailDateToPaymentGroupReports < ActiveRecord::Migration
  def change
    add_column :payment_group_reports, :last_email_date, :datetime
  end
end
