# == Schema Information
#
# Table name: payments
#
#  id                       :integer          not null, primary key
#  total_payment_in_cents   :integer
#  principal_reserve_id     :integer
#  payment_group_id         :integer
#  payment_method           :integer
#  payment_method_number    :string(255)
#  status                   :string(255)      default("Listo")
#  in_aptour                :boolean          default(FALSE)
#  payment_date             :date
#  commission_in_cents      :integer          default(0)
#  iva_in_cents             :integer          default(0)
#  iibb_perception_in_cents :integer          default(0)
#  iva_perception_in_cents  :integer          default(0)
#  cotization_in_cents      :integer
#  total_debt_in_cents      :integer
#  id_mov_in_aptour         :string(255)
#  ig_retention_in_cents    :integer          default(0)
#  eur_cotization_in_cents  :integer
#

require 'test_helper'

class PaymentTest < ActiveSupport::TestCase

  def setup
    @payment = payments(:payment_one)
  end

  test "should have an associated payment_group" do
    assert_not_nil @payment.payment_group
  end

  test 'should have an associated account' do
    assert_not_nil @payment.account
  end

  test "should not save without total_debt" do
    payment = Payment.new
    payment.valid?

    assert_includes payment.errors[:total_debt], 'no puede estar en blanco'
  end

end
