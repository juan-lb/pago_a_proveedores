class PaymentGroupDestroyerManager

  def initialize(payment_group)
    @payment_group = payment_group
    @register_ids = []
  end

  def call
    debits = @payment_group.services.debits

    debits.each do |serv|
      service_register = ServiceRegister.find_by(
        operator_aptour_id: serv.operator_aptour_id,
        id_res: serv.reserve_id,
        numero: serv.service_number
      )

      @register_ids << service_register.id if service_register
    end

    self
  end

  def register_ids
    @register_ids
  end

end
