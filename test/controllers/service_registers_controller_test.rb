require 'test_helper'

class ServiceRegistersControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user   = profiles(:alfonsin)
    @payment_group = payment_groups(:payment_group_one)

    WebMock.stub_request(:get, /.*current/).
      to_return(status: 200, body: "", headers: {})
    WebMock.stub_request(:post, /.*multiple_operators_payments/).
      to_return(
        status: 200,
        body: File.new('test/api_mocks/multiple_operators_payments.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

  test 'should add a service to an existing payment_group' do
    services_amount  = @payment_group.services.count
    total_in_cents   = @payment_group.total_in_cents
    service_register = service_registers(:pesos_debit_three)

    diff = @payment_group.in_pesos? ? service_register.dif_in_cents : service_register.difus_in_cents

    post :add_services,
      register_filter: {
        operator_id: service_register.operator_aptour_id,
        register_ids: [service_register.id]
      },
      format: :js

    @payment_group.reload

    assert_response :success
    assert @payment_group.draft?
    assert @payment_group.services.include?(Service.unscoped.last)
    assert_equal total_in_cents + diff, @payment_group.total_in_cents
    assert_equal services_amount + 1, @payment_group.services.count
  end

  test 'should not add a service to a payment group if has been added' do
    services_amount  = @payment_group.services.count
    total_in_cents   = @payment_group.total_in_cents
    service_register = service_registers(:pesos_debit)

    post :add_services,
      register_filter: {
        operator_id: service_register.operator_aptour_id,
        register_ids: [service_register.id]
      },
      format: :js

    @payment_group.reload

    assert_response :success
    assert @payment_group.draft?
    assert @payment_group.services.include?(services(:service_one))
    assert_equal total_in_cents, @payment_group.total_in_cents
    assert_equal services_amount, @payment_group.services.count
  end

  test 'should add services to a new payment_group' do
    payment_groups(:payment_group_one).update(status: Const::PAYMENT_STATUS_CLOSED) # Ignora al payment_group creado

    payment_groups_amount = PaymentGroup.count
    service_register      = service_registers(:pesos_debit_three)

    post :add_services,
      register_filter: {
        operator_id: service_register.operator_aptour_id,
        register_ids: [service_register.id]
      },
      format: :js

    updated_payment_group = PaymentGroup.unscoped.last

    assert_response :success
    assert_equal payment_groups_amount + 1, PaymentGroup.count
    assert updated_payment_group.draft?
    assert_equal service_registers(:pesos_debit_three).difus_in_cents, updated_payment_group.total_in_cents
    assert_equal 1, updated_payment_group.services.count

  end

  test 'should remove a service from a payment_group' do
    service = services(:service_one)

    post :remove_services,
      register_filter: {
        operator_id: service.operator_aptour_id,
        register_ids: [service.id]
      },
      format: :js

    @payment_group.reload

    assert_response :success
    assert @payment_group.draft?
    assert_equal @payment_group.services.sum(:amount_in_cents)/10_000.to_f, @payment_group.total.to_f
    assert_equal 1, @payment_group.services.count
  end

  test 'should remove all the services from a payment_group' do
    services_amount = Service.count
    payments_amount = PaymentGroup.count
    service_one     = services(:service_one)
    service_two     = services(:service_two)

    post :remove_services,
      register_filter: {
        operator_id: service_one.operator_aptour_id,
        register_ids: [service_one.id, service_two.id]
      },
      format: :js

    assert_response :success
    assert_equal    payments_amount - 1, PaymentGroup.count
    assert_equal    services_amount - 2, Service.count
  end

  test 'should find service_registers by reserve file number' do
    xhr :get, :by_file_number, file_number: 1, format: :js

    assert_response :success
    assert_equal 1, assigns(:operators).size
  end

end
