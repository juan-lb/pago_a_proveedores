class PaymentGroupManager

  NO_ERROR    = 'No existen errores.'
  EMPTY_ERROR = 'El pago debe ser mayor a cero y contener al menos un servicio con deuda.'
  DRAFT_ERROR = 'Existe otro pago en estado BORRADOR del mismo operador.'

  def initialize(payment_group:, current_user: )
    @payment_group = payment_group
    @current_user  = current_user
  end

  def add_services(service_registers)
    services = []
    Service.transaction do
      services = build_services_not_in_payment_group_yet(service_registers)
      Service.import services
      update_payment_group_data
      service_registers.update_all(marked: true)
    end
  end

  def remove_services(services)
    Service.transaction do
      Service.service_registers(services).update_all(marked: false)
      services.destroy_all

      if @payment_group.services.empty?
        @payment_group.destroy
      else
        update_payment_group_data
      end

    end
  end

  def change_currency
    old_currency = @payment_group.currency
    ActiveRecord::Base.transaction do
      services_to_remove = @payment_group.services.select { |service| service.currency_type == old_currency }

      return unless services_to_remove.any?

      services = _services(services_to_remove.map { |each| each.id })
      Service.service_registers(services).update_all(marked: false)
      services.destroy_all
      update_payment_group_data_and_currency(old_currency)
    end
  end

  def remove_incompatible_services
    ActiveRecord::Base.transaction do
      services_to_remove = @payment_group.services.select { |service| service.currency_type != @payment_group.currency }

      return unless services_to_remove.any?

      services = _services(services_to_remove.map { |each| each.id })
      Service.service_registers(services).update_all(marked: false)
      services.destroy_all
      update_payment_group_data
    end
  end

  def process_credit
    return EMPTY_ERROR if @payment_group.credit_with_no_debits?

    @payment_group.build_payment(total_debt: @payment_group.total)
    @payment_group.update_attributes(status: Const::PAYMENT_STATUS_IN_PROCESS)

    NO_ERROR
  end

  def change_to_draft
    return DRAFT_ERROR if exists_draft?

    if @payment_group.payment
      @payment_group.payment.destroy
      @payment_group.reload
    end

    @payment_group.update status: Const::PAYMENT_STATUS_DRAFT

    NO_ERROR
  end

  private

  def build_service(service_register)
    service = Service.new(
      reserve_id:         service_register.id_res,
      service_number:     service_register.numero,
      amount:             service_register.service_dif,
      operator_aptour_id: service_register.operator_aptour_id,
      provider_aptour_id: service_register.provider_aptour_id,
      operator_id:        service_register.id_ope,
      date:               service_register.fecha,
      date_in:            service_register.fec_in,
      date_out:           service_register.fec_out,
      leg_ope:            service_register.leg_ope,
      viajeroresponsable: service_register.viajeroresponsable,
      details:            service_register.det_prev2,
      currency:           service_register.moneda,
      seller_aptour_id:   service_register.reserve.try(:id_usu),
      payment_group:      @payment_group
    )

    if service_register.det_prev2.include?('Costo en Euros:')
      service.euros = service_register.det_prev2.split(': ').last.to_f
    end

    service
  end

  def update_payment_group_data
    @payment_group.update(
      is_credit: (services_total <= 0),
      total:     services_total,
      profile:   @current_user
    )
  end

  def update_payment_group_data_and_currency(old_currency)
    new_currency = old_currency == "P" ? "D" : "P"

    @payment_group.update(
      is_credit: (services_total <= 0),
      currency:  new_currency,
      total:     services_total,
      profile:   @current_user
    )
  end

  def services_total
    @services_total ||= (@payment_group.
      services.
      sum(:amount_in_cents)/10_000.to_f).
      round(2)
  end

  def build_services_not_in_payment_group_yet(service_registers)
    service_registers.not_marked.map { |service_register| build_service(service_register) }
  end

  private

  def _services(services_ids)
    Service.where(id: services_ids)
  end

  def exists_draft?
    @payment_group.operator.payment_groups.draft.count.positive?
  end

end
