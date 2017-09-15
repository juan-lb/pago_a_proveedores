class ReservePresenter

  def initialize(reserve:, params:)
    @reserve            = reserve
    @params             = params
    @operators_payments = OperatorsPayments.new(reserve.reserve_id)
  end

  def operator
    @operator ||= Operator.find_by(
      aptour_id: @params[:operator_aptour_id]
    )
  end

  def services
    @services ||= @reserve.service_registers.where(
      operator_aptour_id: operator.aptour_id
    )
  end

  def other_services
    @other_services ||= @reserve.service_registers.where.not(
      operator_aptour_id: operator.aptour_id
    )
  end

  def current_service
    return @current_service unless @current_service.nil?

    @current_service =
      if @params[:service_register_id]
        ServiceRegister.find(@params[:service_register_id])
      else
        Service.find(@params[:service_id]).service_register
      end
  end

  def total
    @total ||= services.reduce(0) do |sum, serv|
      sum + serv.service_dif
    end
  end

  def other_services_total
    @other_total ||= other_services.reduce(0) do |sum, service|
      sum + service.service_dif
    end
  end

  def localized_services
    @localized_services ||= localize_services
  end

  def operators_payments
    @payments ||= @operators_payments.payments
  end

  def operator_payment
    @operator_payment ||= @operators_payments.operator_payment operator.aptour_id
  end

  def ars_operators_payments
    @ars_payments ||= @operators_payments.ars_total
  end

  def usd_operators_payments
    @usd_payments ||= @operators_payments.usd_total
  end

  def draft_payment?
    return @draft_payment unless @draft_payment.nil?

    @draft_payment = @params[:draft_payment] ? false : true
  end

  def passengers
    return @passengers unless @passengers.nil?

    con = Connection.new(ENV['APTOUR_URL'])
    res = con.get_paxs_by_file_number(@reserve.reserve_id)

    return [] unless res.status == 200

    @passengers = res.body.map { |each| each['nombre'].strip }
  end

  private

  def localize_services
    return [] unless current_service.leg_ope.present?

   ServiceRegister.where(
      leg_ope:            current_service.leg_ope,
      id_res:             @reserve.reserve_id,
      operator_aptour_id: operator.aptour_id
    )
  end

end
