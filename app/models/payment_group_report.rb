# == Schema Information
#
# Table name: payment_group_reports
#
#  id               :integer          not null, primary key
#  payment_group_id :integer
#  note             :text(65535)
#  swift            :text(65535)
#  printable_column :integer          default(1)
#  euros_difference :float(24)
#  last_email_date  :datetime
#

class PaymentGroupReport < ActiveRecord::Base

  # -- Associations
  belongs_to :payment_group
  has_many :services, through: :payment_group

end
