class ServicesControllerTest < ActionController::TestCase

  def setup
    authenticate
    stub_api_requests

    current_user = profiles(:alfonsin)

    @service = services(:service_one)
  end

  test 'should get edit' do
    xhr :get, :edit, id: @service.id

    assert_response :success
    assert_not_nil assigns(:service)
    assert_equal @service, assigns(:service)
  end

  test 'should update' do
    params = {
      amount:  1000,
      leg_ope: 'Locator'
    }

    xhr :put, :update, id: @service.id, service: params

    assert_response :success
    assert_not_nil assigns(:service)
    assert_equal @service, assigns(:service)
  end

  test 'should update service' do
    params = {
      amount:  1000,
      leg_ope: 'Locator'
    }

    xhr :put, :update_service, id: @service.id, service: params

    assert_response :success
    assert_not_nil assigns(:service)
    assert_equal @service, assigns(:service)
    assert_nil flash[:error]
  end

  test 'should not update service with negative balance' do
    params = {
      amount:  -1000,
      leg_ope: 'Locator'
    }

    service = services(:service_five)

    xhr :put, :update_service, id: service.id, service: params

    assert_response :success
    assert_not_nil assigns(:service)
    assert_equal service, assigns(:service)
    assert_equal ServiceUpdater::NEGATIVE_BALANCE_ERROR, flash[:error]
  end

  private

  def stub_api_requests
    WebMock.stub_request(:get, /.*peso\/dolar\/bsp/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/usd_cotization.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

end
