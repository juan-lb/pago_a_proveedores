# == Schema Information
#
# Table name: services
#
#  id                 :integer          not null, primary key
#  reserve_id         :integer
#  agency_id          :integer
#  leg_ope            :string(255)
#  service_number     :integer
#  amount_in_cents    :integer
#  date               :datetime
#  date_out           :datetime
#  viajeroresponsable :string(255)
#  operator_id        :integer
#  payment_group_id   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_valid           :boolean          default(TRUE)
#  euros              :float(24)
#  details            :text(65535)
#  operator_aptour_id :integer
#  currency           :string(255)
#  date_in            :datetime
#  seller_aptour_id   :string(4)
#  provider_aptour_id :integer
#

require 'test_helper'

class ServiceTest < ActiveSupport::TestCase

  def setup
    @service = services(:service_one)
  end

  test "should create a service" do
    assert_not_nil @service.id
  end

  test 'should have an associated operator' do
    assert_not_nil @service.operator
  end

  test 'should have an associated payment_group' do
    assert_not_nil @service.payment_group
  end

end
