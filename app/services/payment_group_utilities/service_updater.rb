class ServiceUpdater

  NO_ERROR               = "No existen errores"
  NEGATIVE_BALANCE_ERROR = "El nuevo monto no puede ser menor al ingresado"

  def initialize(service: ,params:)
    @service       = service
    @params        = params
    @payment_group = @service.payment_group
  end

  def call
    new_value = amount

    return NEGATIVE_BALANCE_ERROR if exists_a_negative_balance?(value: new_value) && is_credit?

    ActiveRecord::Base.transaction do
      difference = @service.amount - new_value
      @service.euros = @params[:euros] if @params[:euros].present?
      @service.leg_ope = @params[:leg_ope] if @params[:leg_ope].present?
      @service.amount = new_value
      @service.save

      update_payment_group_data difference
    end

    NO_ERROR
  end

  private

  def amount
    @params[:amount].to_d
  end

  def update_payment_group_data(difference)
    total = @payment_group.total - difference

    @payment_group.update(
      total:     total,
      is_credit: total <= 0
    )
  end

  def is_credit?
    @service.amount < 0
  end

  def exists_a_negative_balance?(value:)
    value < @service.service_register.service_dif
  end

end
