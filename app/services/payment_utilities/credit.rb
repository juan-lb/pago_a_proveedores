class Credit

  def initialize(payment_group)
    @payment_group = payment_group
  end

  def call
    @payment_group.payment.update(in_aptour: true)

    if @payment_group.is_refund?
      response = pay_refund
      return response unless response.ok?
    end

    response = Transference.new(@payment_group).call

    if response.ok?
      @payment_group.payment.update(status: "Realizado")
    end

    response
  end

  private

  def pay_refund
    account  = Account.find_by_api_id(
      @payment_group.payment.payment_method
    )
    klass    = FromTo.new(@payment_group, account).call
    response = klass.constantize.new(@payment_group).call_for_refund

    response
  end

end
