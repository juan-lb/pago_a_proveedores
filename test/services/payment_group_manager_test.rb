require 'test_helper'

class PaymentGroupManagerTest < ActiveSupport::TestCase

  def setup
    @payment_group = payment_groups(:payment_group_one)
    @manager = PaymentGroupManager.new(
      payment_group: @payment_group,
      current_user: profiles(:alfonsin)
    )
  end

  test "should have two associated services" do
    assert_equal 2, @payment_group.services.count
    assert       @payment_group.draft?
  end

  test "should add a service" do
    pesos_debit = service_registers(:pesos_debit)
    pesos_debit.numero = 666 # Cambio numero para que no tenga servicio asociado y lo pueda agregar al pago
    pesos_debit_collection = ServiceRegister.where(id: pesos_debit.id)

    @manager.add_services(pesos_debit_collection)

    pesos_debit.reload
    @payment_group.reload

    assert @payment_group.services.any?
    assert pesos_debit.marked, "Should be marked"
    refute @payment_group.is_credit, "Should not be a credit"
    assert @payment_group.draft?
  end

  test "should add a credit service and be set as credit" do
    dollars_credit = service_registers(:dollars_credit).reload
    dollars_credit_collection = ServiceRegister.where(id: dollars_credit.id)

    @manager.add_services(dollars_credit_collection)

    @payment_group.reload
    dollars_credit.reload

    assert @payment_group.services.any?
    assert dollars_credit.marked, "Should be marked"
    assert @payment_group.is_credit, "Should be a credit"
    assert @payment_group.draft?
  end

  test "should remove a service" do
    pesos_debit = service_registers(:pesos_debit_two)
    services_quantity = @payment_group.services.count
    service = Service.where(id: @payment_group.services.last.id)

    @manager.remove_services(service)

    pesos_debit.reload

    assert_equal services_quantity - 1, @payment_group.services.count
    refute pesos_debit.marked, "Should not be marked"
    assert @payment_group.draft?
  end

end
