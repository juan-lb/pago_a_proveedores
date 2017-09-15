class Transference

  def initialize(payment_group)
    @payment_group = payment_group
    @payment       = payment_group.payment
    @connection    = Connection.new(ENV["APTOUR_URL"])
    @response      = Response.new
  end

  def call
    if @payment_group.is_refund?
      create_transfers
      pay_credits
    else
      create_transfers_and_credits
      pay_credits
      pay_transfers
    end

    @response
  end

  private

  def create_transfers_and_credits
    transfers  = Hash.new
    total_debt = @payment_group.debts_amount

    @payment_group.services.each do |service|
      next if service.reserve_id == @payment.principal_reserve_id

      transfers[service.reserve_id] = 0.to_d unless transfers[service.reserve_id].present?
      transfers[service.reserve_id] += service.amount
    end

    transfers.each_key do |k|
      credit = transfers[k] < 0

      unless (total_debt < 0) && credit
        accumulated = total_debt
        accumulated += transfers[k] if credit

        Transfer.create(
          amount: total_to_transfer(accumulated, transfers[k], credit),
          reserve_id: k,
          payment: @payment,
          credit: credit,
          transfer_date: DateTime.now.to_date
        )
      end

      total_debt += transfers[k] if credit
    end

  end

  def create_transfers
    transfers = Hash.new

    @payment_group.services.each do |service|
      next if service.reserve_id == @payment.principal_reserve_id

      transfers[service.reserve_id] = 0.to_d unless transfers[service.reserve_id].present?
      transfers[service.reserve_id] += service.amount
    end

    transfers.each_key do |k|
      Transfer.create(
        amount: total_to_transfer(0, transfers[k], true),
        reserve_id: k,
        payment: @payment,
        credit: true,
        transfer_date: DateTime.now.to_date
      )
    end
  end

  def pay_credits
    @payment.transfers.where(credit: true).each do |tr|
      pay_credit tr
    end
  end

  def pay_credit(transfer)
    transfer.update(transfer_date: Date.today)

    response = @connection.transfer_reserve(
      transfer.amount.abs,
      @payment_group.operator_aptour_id,
      transfer.reserve_id,
      @payment.principal_reserve_id,
      @payment_group.currency
    )

    if response.status == 200
      transfer.update(in_aptour: true)
    else
      @response.add_error('transfer_reserve', response.status, response.body)
    end

  rescue Faraday::ConnectionFailed
    @response.add_error('transfer_reserve', 666, 'Fallo de conexión')
  end

  def pay_transfers
    return unless @payment.in_aptour

    @payment.transfers.where(credit: false).each do |tr|
      pay_transfer tr
    end
  end

  def pay_transfer(transfer)
    transfer.update(transfer_date: Date.today)

    response = @connection.transfer_reserve(
      transfer.amount,
      @payment_group.operator_aptour_id,
      @payment.principal_reserve_id,
      transfer.reserve_id,
      @payment_group.currency
    )

    if response.status == 200
      transfer.update(in_aptour: true)
    else
      @response.add_error('transfer_reserve', response.status, response.body)
    end

  rescue Faraday::ConnectionFailed
    @response.add_error('transfer_reserve', 666, 'Fallo de conexión')
  end

  def total_to_transfer(accumulated, amount, is_credit)
    return amount unless is_credit

    if accumulated > 0
      amount
    else
      amount - accumulated
    end

  end

end
