class FakePaymentGroupManager

  def initialize(services_ids, principal_reserve, refund_payment)
    @service_registers = ServiceRegister.where(id: services_ids)
    @principal_reserve = principal_reserve
    @payment_group     = nil
    @refund_payment    = refund_payment
  end

  def call
    ActiveRecord::Base.transaction do
      @payment_group = generate_payment_group

      PaymentGroupManager.new(
        payment_group: @payment_group,
        current_user:  @refund_payment.profile
      ).add_services(@service_registers)

      generate_payment

      Transaction.new(@payment_group.reload).call
    end
  end

  private

  def generate_payment_group
    operator = Operator.find_by(
      aptour_id: @service_registers.first.operator_aptour_id
    )

    PaymentGroup.create(
      operator_aptour_id: operator.aptour_id,
      status:             'Cargado',
      profile:            @refund_payment.profile,
      currency:           @service_registers.first.moneda,
      type:               @service_registers.first.payment_group_type,
      category:           operator.category == 'national' ? 1 : 2,
      operator_name:      operator.name
    )
  end

  def generate_payment
    attributes = @refund_payment.payment.attributes.
      slice(
        'total_payment_in_cents',
        'total_debt_in_cents',
        'cotization_in_cents',
        'payment_method',
        'payment_method_number'
      ).
      merge(
        {
          'total_debt'           => @payment_group.total,
          'principal_reserve_id' => @principal_reserve
        }
      )

    @payment_group.create_payment attributes
  end

end
