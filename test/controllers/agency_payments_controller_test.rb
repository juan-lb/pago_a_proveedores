class AgencyPaymentsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)

    WebMock.stub_request(:get, /.*transactions/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/transactions.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil  assigns(:manager)
    assert_not_nil  assigns(:manager).receipts
    assert_not_nil  assigns(:manager).total_ars
    assert_not_nil  assigns(:manager).total_usd
  end

end
