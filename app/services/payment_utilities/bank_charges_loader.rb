class BankChargesLoader < PaymentProcessor

  def call(account)
    erase_table
    return @response unless @response.ok?

    impact(202, @payment.commission)      if @payment.commission?
    impact(67,  @payment.iva)             if @payment.iva?
    impact(322, @payment.iibb_perception) if @payment.iibb_perception?

    total = @payment.commission +
      @payment.iva +
      @payment.iibb_perception

    load_bank_charges total, account

    @response
  end

  private

  def impact(account, amount)
    for_pag_ins(
      account,
      ' ',
      amount,
      1.0000,
      @payment.cotization || 1.0000,
      '',
      '',
      0,
      'D'
    )
  end

end
