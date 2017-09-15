class Transaction

  def initialize(payment_group)
    @payment_group = payment_group
  end

  def call(fake_mode = false, fake_mode_options = {})
    in_euros = @payment_group.has_euros?

    if @payment_group.is_credit?
      response = Credit.new(@payment_group).call

      @payment_group.update(
        status: Const::PAYMENT_STATUS_CLOSED,
        in_euros: in_euros
      ) if response.ok?
    else
      response = Debit.new(@payment_group).call

      if response.ok?
        @payment_group.update(
          status: Const::PAYMENT_STATUS_CLOSED,
          in_euros: in_euros
        )

        @payment_group.payment.update(in_aptour: true)

        response = Transference.new(@payment_group).call
      end
    end

    FakeModeTransaction.new(
      @payment_group,
      fake_mode_options
    ).call if fake_mode

    response
  end

end
