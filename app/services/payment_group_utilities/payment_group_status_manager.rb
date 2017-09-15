class PaymentGroupStatusManager

  attr_accessor :payment_group, :type, :currency, :params

  def initialize(payment_group:, type:, params: {})
    @payment_group = payment_group
    @currency      = payment_group.currency
    @params        = params
    @type          = type
  end

  def process
    case type
    when :international then process_international
    when :refund        then process_refund
    end

    @payment
  end

  def send
    case type
    when :national      then send_national
    when :international then send_international
    end

    LocatorsUpdater.new(payment_group: @payment_group).call

    @payment
  end

  private

  def process_international
    if payment_group.payment.present?
      payment_group.payment.destroy
      payment_group.reload
    end

    payment_group.change_status 0

    payment_group.status = Const::PAYMENT_STATUS_IN_PROCESS
    payment_group.save
  end

  def process_refund
    payment_group.update status: Const::PAYMENT_STATUS_IN_PROCESS

    @payment = payment_group.create_payment(
      total_debt: payment_group.total
    )
  end

  def send_national
    cotization = currency == 'D' ? params[:cotization].to_f : 1

    retention = Retention.new.call(
      operator: payment_group.operator,
      total:    payment_group.total * cotization.to_f
    )
    ig_retention = currency == 'D' ? retention / cotization : retention

    @payment = payment_group.create_payment(
      total_debt:   payment_group.total,
      ig_retention: ig_retention.round(2),
      cotization:   cotization
    )

    payment_group.update_attributes(
      status: Const::PAYMENT_STATUS_SENT,
      sent_date: Time.now,
    )
  end

  def send_international
    @payment = payment_group.create_payment(
      total_debt: params[:total].to_d
    )

    payment_group.change_status 1
    payment_group.update_attributes(
      status:    Const::PAYMENT_STATUS_SENT,
      sent_date: Time.now,
    )
  end

end
