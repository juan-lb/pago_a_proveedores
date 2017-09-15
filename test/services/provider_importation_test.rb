require 'test_helper'

class ProviderImportationTest < ActiveSupport::TestCase

  def setup
    stub_api_requests
  end

  test 'should import providers and delete old ones' do
    ProviderImportation.new.call

    assert_equal JSON.parse(File.new('test/api_mocks/providers.json').read).size, Provider.count
  end

  private

  def stub_api_requests
    stub_request(:get, /.*providers.*/).
    to_return(
      body:    File.new('test/api_mocks/providers.json').read,
      status:  200,
      headers: {'Content-Type' => 'application/json'}
    )
  end

end
