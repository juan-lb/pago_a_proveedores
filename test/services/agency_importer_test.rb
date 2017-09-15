require 'test_helper'

class AgencyImporterTest < ActiveSupport::TestCase

  def setup
    stub_api_requests
  end

  test 'should import agencies' do
    importer = AgencyImporter.new
    reserves = JSON.
      parse(File.new('test/api_mocks/agencies.json').read).
      map { |each| each['id_cliente_aptra'] }.
      compact.
      select { |each| each.positive? }

    Agency.delete_all
    importer.call reserves

    assert_equal reserves.count, Agency.count
    assert_empty importer.wrong_agencies
  end

  test 'should not import agencies' do
    importer = AgencyImporter.new

    Agency.delete_all
    importer.call []

    assert_equal 0, Agency.count
  end

  private

  def stub_api_requests
    stub_request(:get, /.*agencies.*/).
    to_return(
      body:    File.new('test/api_mocks/agencies.json').read,
      status:  200,
      headers: {'Content-Type' => 'application/json'}
    )
  end

end
