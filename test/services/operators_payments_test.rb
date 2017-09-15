require 'test_helper'

class OperatorsPaymentsTest < ActiveSupport::TestCase

  def setup
    stub_api_requests

    @reserve = reserves(:reserve_one)
  end

  test 'should get operators payments for a reserve' do
    manager = OperatorsPayments.new(@reserve.reserve_id)

    assert_not_nil manager.payments
    assert_not_empty manager.payments
    assert_not_empty manager.operator_payment(77)
    assert_equal Float, manager.ars_total.class
    assert_equal Float, manager.usd_total.class
  end

  test 'should not get any operators payments for a non-existing operator' do
    manager = OperatorsPayments.new(@reserve.reserve_id)

    assert_nil manager.operator_payment(0)
  end

  private

  def stub_api_requests
    WebMock.stub_request(:get, /.*operators_payments/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/operators_payments.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

end
