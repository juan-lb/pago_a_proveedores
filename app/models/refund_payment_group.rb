# == Schema Information
#
# Table name: payment_groups
#
#  id                 :integer          not null, primary key
#  status             :string(255)
#  profile_id         :integer
#  operator_id        :integer
#  total_in_cents     :integer          default(0)
#  currency           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  category           :integer
#  operator_name      :string(255)
#  is_credit          :boolean          default(FALSE)
#  type               :string(255)      not null
#  operator_aptour_id :integer
#  in_euros           :boolean          default(FALSE)
#  sent_date          :datetime
#  payment_group_id   :integer
#  adjustment         :boolean          default(FALSE)
#

class RefundPaymentGroup < PaymentGroup

end
