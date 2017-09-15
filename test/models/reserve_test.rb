# == Schema Information
#
# Table name: reserves
#
#  id                 :integer          not null, primary key
#  reserve_id         :integer
#  total_in_cents     :integer
#  paid_in_cents      :integer
#  used_in_cents      :integer          default(0)
#  total_usd_in_cents :integer
#  paid_usd_in_cents  :integer
#  used_usd_in_cents  :integer          default(0)
#  agency_aptour_id   :integer
#  id_usu             :string(255)
#  observations       :text(65535)
#  client_details     :text(65535)
#  fec_ape            :date
#  id_operes          :string(255)
#  debt_in_cents      :integer          default(0)
#  debt_usd_in_cents  :integer          default(0)
#

require 'test_helper'

class ReserveTest < ActiveSupport::TestCase

  def setup
    @reserve = reserves(:reserve_one)
  end

  test "should create a reserve" do
    assert_not_nil @reserve.id
  end

  test 'should have an associated agency' do
    assert_not_nil @reserve.agency
  end

  test 'should have associated service_registers' do
    assert_equal 2, @reserve.service_registers.count
  end

  test 'should have an associated user' do
    assert_not_nil @reserve.user
  end

  test 'should have an associated operative' do
    assert_not_nil @reserve.operative
  end

end
