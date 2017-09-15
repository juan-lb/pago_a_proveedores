require 'test_helper'

class CotizatorTest < ActiveSupport::TestCase

  def setup
    stub_api_requests
  end

  test 'should get usd cotization' do
    cotization = Cotizator.new.usd_cotization

    assert_equal Float, cotization.class
    assert cotization > 0
  end

  test 'should get eur cotization' do
    cotization = Cotizator.new.eur_cotization

    assert_equal Float, cotization.class
    assert cotization > 0
  end

  private

  def stub_api_requests
    WebMock.stub_request(:get, /.*peso\/dolar\/bsp/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/usd_cotization.json').read,
        headers: {'Content-Type' => 'application/json'}
    )

    WebMock.stub_request(:get, /.*peso\/euro\/base/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/eur_cotization.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

end
