class EntryLoader < PaymentProcessor

  def call(account_id, operation)
    set_impact_params

    erase_table
    return @response unless @response.ok?

    impact(account_id, operation == :expenditure ? 'D' : 'C' )
    return @response unless @response.ok?

    impact(@payment.payment_method, operation == :income ? 'D' : 'C')
    return @response unless @response.ok?

    currency = Account.find_by(
      account_api_id: @payment.payment_method
    ).simple_currency

    if @compensate
      compensate
      return @response unless @response.ok?
    end

    type = operation == :expenditure ? 'E' : 'I'
    custom_asiento_ins(@payment.total_payment, currency, type)

    @response
  end

  private

  def impact(account_id, operation_type)
    for_pag_ins(
      account_id,
      @account_type,
      @payment.total_payment,
      @cotization_1,
      @cotization_2,
      '',
      Date.today,
      0,
      operation_type
    )
  end

  def compensate
    total = (@payment.total_payment / @payment.cotization) -
      @payment.total_payment

    for_pag_ins(
      63,
      'E',
      total,
      1.0000,
      1.0000,
      @payment.payment_method_number,
      Date.today,
      0,
      'D'
    )
  end

  def set_impact_params
    account = Account.find_by(
      account_api_id: @payment.payment_method
    )

    @compensate = false

    if account.pesos? && @payment_group.in_pesos?
      @cotization_1 = 1.0000
      @cotization_2 = 1.0000
      @account_type = 'B'
    elsif account.dollars? && @payment_group.in_dollars?
      @cotization_1 = 1.0000
      @cotization_2 = @payment.cotization
      @account_type = 'E'
    else
      @cotization_1 = @payment.cotization
      @cotization_2 = 1.0000
      @account_type = 'E'
      @compensate   = true
    end
  end

end
