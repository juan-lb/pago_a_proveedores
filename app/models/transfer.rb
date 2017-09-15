# == Schema Information
#
# Table name: transfers
#
#  id              :integer          not null, primary key
#  payment_id      :integer
#  reserve_id      :integer
#  in_aptour       :boolean          default(FALSE)
#  amount_in_cents :integer
#  error           :string(255)
#  transfer_date   :date
#  credit          :boolean
#

class Transfer < ActiveRecord::Base
  belongs_to :payment

  def self.attributes_in_cents
    ['amount']
  end

  include IntegerInCents

end
