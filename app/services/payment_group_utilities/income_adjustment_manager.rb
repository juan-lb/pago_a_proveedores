class IncomeAdjustmentManager

  def initialize(payment_group, coefficient, comment)
    @new_payment_group = nil
    @payment_group     = payment_group
    @coefficient       = coefficient.to_f / 100
    @comment           = comment
  end

  def call
    ActiveRecord::Base.transaction do
      create_payment_group
      create_services
      create_payment
      update_services
      update_payment_group
    end

    @new_payment_group
  end

  private

  def create_payment_group
    @new_payment_group = PaymentGroup.create(
      operator_aptour_id: @payment_group.operator_aptour_id,
      status:             'Enviado',
      sent_date:          Time.now,
      total:              @payment_group.total * @coefficient,
      profile:            @payment_group.profile,
      currency:           @payment_group.currency,
      type:               @payment_group.type,
      category:           @payment_group.category,
      operator_name:      @payment_group.operator_name,
      payment_group:      @payment_group,
      adjustment:         true
    )
  end

  def create_services
    @payment_group.services.each do |service|
      Service.create(
        reserve_id:         service.reserve_id,
        service_number:     service.service_number,
        amount:             service.amount * @coefficient,
        operator_aptour_id: service.operator_aptour_id,
        operator_id:        service.operator_id,
        date:               service.date,
        date_in:            service.date_in,
        date_out:           service.date_out,
        leg_ope:            service.leg_ope,
        viajeroresponsable: service.viajeroresponsable,
        details:            service.details,
        currency:           service.currency,
        seller_aptour_id:   service.seller_aptour_id,
        payment_group:      @new_payment_group
      )
    end
  end

  def create_payment
    total   = @payment_group.total * @coefficient
    account = @payment_group.currency == 'D' ? 460 : 92

    attributes =
      {
        'total_debt'            => total,
        'total_payment'         => total,
        'cotization'            => Cotizator.new.usd_cotization,
        'payment_method_number' => @comment,
        'payment_method'        => account
      }

    @new_payment_group.create_payment attributes
  end

  def update_services
    @payment_group.services.each do |service|
      service.amount *= (1 - @coefficient)
      service.save
    end
  end

  def update_payment_group
    services_total = @payment_group.services.sum(:amount_in_cents)/10_000.to_f

    @payment_group.update(
      payment_group: @new_payment_group,
      total:         services_total
    )
  end

end
