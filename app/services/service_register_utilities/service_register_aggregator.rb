class ServiceRegisterAggregator

  def initialize(registers_ids:, current_user:, destiny: :payment)
    @service_registers = _service_registers(registers_ids)
    @current_user      = current_user
    @destiny           = destiny.to_sym
  end

  def call
    PaymentGroupManager.new(
      payment_group: find_or_create_payment_group,
      current_user: @current_user
    ).add_services(@service_registers)
  end

  private

  def find_or_create_payment_group
    operator = Operator.find_by(aptour_id: operator_aptour_id)

    PaymentGroup.where(
      operator_aptour_id: operator_aptour_id,
      status: 'Borrador'
    ).first_or_create do |pg|
      pg.operator_aptour_id = operator_aptour_id
      pg.profile            = @current_user
      pg.currency           = currency
      pg.type               = type
      pg.status             = 'Borrador'
      pg.category           = operator.category == 'national' ? 1 : 2
      pg.operator_name      = operator.name
    end
  end

  def _service_registers(registers_ids)
    ServiceRegister.where(id: registers_ids)
  end

  def operator_aptour_id
    @service_registers.first.operator_aptour_id
  end

  def currency
    @service_registers.first.moneda
  end

  def type
    return 'RefundPaymentGroup' if @destiny == :refund

    @service_registers.first.payment_group_type
  end

end
