class ReserveProcessorTest < ActiveSupport::TestCase

  def setup
    stub_api_requests

    @reserve = reserves(:reserve_one)
  end

  test 'should get reserve data' do
    processor = ReserveProcessor.new(@reserve.reserve_id)

    reserve = processor.call

    assert_not_nil reserve
    assert reserve.valid?
    assert_not_nil processor.reserve_data
    assert_equal Hash, processor.reserve_data.class
    assert processor.debt >= 0
    assert processor.debt_usd => 0
    assert_not_empty processor.services
  end

  private

  def stub_api_requests
    WebMock.stub_request(:get, /.*reserves/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/reserve.json').read,
        headers: {'Content-Type' => 'application/json'}
    )

    WebMock.stub_request(:post, /.*reserves\/services/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/reserve_services.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

end
