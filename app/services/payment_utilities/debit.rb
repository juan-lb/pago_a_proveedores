class Debit

  def initialize(payment_group)
    @payment_group = payment_group
    @account = Account.find_by_api_id(payment_group.payment.payment_method)
  end

  def call
    klass    = FromTo.new(@payment_group, @account).call
    response = klass.constantize.new(@payment_group).call

    if @payment_group.type == 'NationalPaymentGroup'
      update_operator_accumulated()
    end

    response
  end

  private

  def update_operator_accumulated
    ig = IgRetention.find_by(operator_aptour_id: @payment_group.operator_aptour_id)

    return if ig.nil?

    accumulated = (ig.accumulated + (@payment_group.total * @payment_group.payment.cotization))

    ig.update(accumulated: accumulated)
  end

end
