class PesoToPeso < PaymentProcessor

  def call
    erase_table
    return @response unless @response.ok?

    impact_retention
    return @response unless @response.ok?

    impact_payment('C')
    return @response unless @response.ok?

    pay_reserve(@payment.total_payment + @payment.ig_retention)

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

  def impact_retention
    load_retention

    for_pag_ins(
      376,
      'B',
      @payment.ig_retention,
      1.0000,
      1.0000,
      @payment.payment_method_number,
      Date.today,
      0,
      'C'
    )
  end

  def impact_payment(operation_type)
    for_pag_ins(
      @payment.payment_method,
      @account["type"],
      @payment.total_payment,
      1.0000,
      1.0000,
      @payment.payment_method_number,
      Date.today,
      0,
      operation_type
    )
  end

end
