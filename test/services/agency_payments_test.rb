require 'test_helper'

class AgencyPaymentsTest < ActiveSupport::TestCase

  def setup
    stub_api_requests
  end

  test 'should get receipts' do
    params = {
      from: Date.new(2017, 1, 7),
      to:   Date.new(2017, 1, 31)
    }

    manager = AgencyPayments.new params

    assert_not_nil manager
    assert_not_nil manager.receipts
    assert_not_nil manager.total_ars
    assert_not_nil manager.total_usd
    assert_not_empty manager.receipts
  end

  private

  def stub_api_requests
    WebMock.stub_request(:get, /.*transactions/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/transactions.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

end
