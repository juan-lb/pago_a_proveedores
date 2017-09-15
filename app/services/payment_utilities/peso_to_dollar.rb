class PesoToDollar < PaymentProcessor

  def call
    make_payment
    bank_charges

    @response
  end

  def call_for_refund
    erase_table
    return @response unless @response.ok?

    impact_payment('D')
    return @response unless @response.ok?

    compensate('D')
    return nil unless @response.ok?

    pay_refund(@payment.total_payment / @payment.cotization)

    @response
  end

  private

  def make_payment
    erase_table
    return nil unless @response.ok?

    impact_retention
    return nil unless @response.ok?

    impact_payment('C')
    return nil unless @response.ok?

    compensate('C')
    return nil unless @response.ok?

    pay_reserve((@payment.total_payment / @payment.cotization) + @payment.ig_retention)
  end

  def bank_charges
    erase_table

    impact(202, @payment.commission)      if @payment.commission?
    impact(67,  @payment.iva)             if @payment.iva?
    impact(322, @payment.iibb_perception) if @payment.iibb_perception?
    impact(25,  @payment.iva_perception)  if @payment.iva_perception?

    total = @payment.commission +
      @payment.iva +
      @payment.iibb_perception +
      @payment.iva_perception

    load_bank_charges total
  end

  def impact_retention
    load_retention

    for_pag_ins(
      376,
      'B',
      @payment.ig_retention * @payment.cotization,
      @payment.cotization,
      1.0000,
      @payment.payment_method_number,
      Date.today,
      0,
      'C'
    ) if @payment.ig_retention > 0
  end

  def impact_payment(operation_type)
    for_pag_ins(
      @payment.payment_method,
      'E',
      @payment.total_payment,
      @payment.cotization,
      1.0000,
      @payment.payment_method_number,
      Date.today,
      0,
      operation_type
    )
  end

  def compensate(operation_type)
    total_in_usd = (@payment.total_payment / @payment.cotization) + @payment.ig_retention
    compensation_total = total_in_usd - @payment.total_payment - (@payment.ig_retention * @payment.cotization)

    for_pag_ins(
      63,
      'E',
      compensation_total,
      1.0000,
      1.0000,
      @payment.payment_method_number,
      Date.today,
      0,
      operation_type
    )
  end

  def impact(account, amount)
    account_type = (@payment_group.category == 2) ? ' ' : 'E'

    for_pag_ins(
      account,
      account_type,
      amount,
      1.0000,
      1.0000,
      '',
      '',
      0,
      'D'
    )
  end

end
