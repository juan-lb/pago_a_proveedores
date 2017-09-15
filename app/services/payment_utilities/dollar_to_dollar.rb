class DollarToDollar < PaymentProcessor

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

    pay_refund(@payment.total_payment)

    @response
  end

  private

  def make_payment
    erase_table
    return nil unless @response.ok?

    impact_payment('C')
    return nil unless @response.ok?

    pay_reserve(@payment.total_payment)
  end

  def bank_charges
    erase_table
    impact_commission if @payment.commission?
    impact_iva        if @payment.iva?

    total = @payment.commission + @payment.iva

    load_bank_charges total
  end

  def impact_payment(operation_type)
    for_pag_ins(
      @payment.payment_method,
      'E',
      @payment.total_payment,
      1.0000,
      @payment.cotization,
      @payment.payment_method_number,
      Date.today,
      0,
      operation_type
    )
  end

  def impact_commission
    for_pag_ins(
      202,
      'E',
      @payment.commission,
      1.0000,
      1.0000,
      '',
      '',
      0,
      'D'
    )
  end

  def impact_iva
    for_pag_ins(
      21,
      'E',
      @payment.iva,
      1.0000,
      1.0000,
      '',
      '',
      0,
      'D'
    )
  end

end
