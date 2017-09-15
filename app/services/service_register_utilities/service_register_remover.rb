class ServiceRegisterRemover

  def initialize(services_ids:, current_user:)
    @services     = _services(services_ids)
    @current_user = current_user
  end

  def call
    payment_group = PaymentGroup.find_by(
      operator_aptour_id: operator_aptour_id,
      status: 'Borrador'
    )

    PaymentGroupManager.new(
      payment_group: payment_group,
      current_user: @current_user
    ).remove_services(@services)
  end


  private

  def _services(services_ids)
    Service.where(id: services_ids)
  end

  def operator_aptour_id
    @services.first.operator_aptour_id
  end

end
