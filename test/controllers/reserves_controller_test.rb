class ReservesControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)
    @service_register = service_registers(:pesos_debit)
    @reserve          = @service_register.reserve
  end

  test 'should get a reserve' do
    WebMock.stub_request(:get, /.*operators_payments/).
      to_return(
        status: 200,
        body:   File.new('test/api_mocks/operators_payments.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
    WebMock.stub_request(:get, /.*paxs/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/paxs.json').read,
        headers: {'Content-Type' => 'application/json'}
    )

    xhr :get, :show,
      id: @reserve.id,
      service_register_id: @service_register.id,
      operator_aptour_id: operators(:national).aptour_id

    assert_response :success
    assert_not_nil assigns(:presenter)
  end

end
