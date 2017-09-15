class ServiceRegistersIndexAgent

  NO_ERROR            = "No existen errores."
  BEEPER_ERROR        = "El servicio con el localizador ingresado ya fue agregado a un pago."
  WRONG_RESERVE_ERROR = "Existen errores de importación con la reserva indicada."

  def initialize(presenter:, filter_params:)
    @presenter = presenter
    @reserve   = filter_params[:reserve].to_i
    @beeper    = filter_params[:beeper]
  end

  def call
    return NO_ERROR            if @presenter.debits.count > 0
    return BEEPER_ERROR        if exists_beeper_error
    return WRONG_RESERVE_ERROR if exists_reserve_error

    NO_ERROR
  end

  private

  def exists_beeper_error
    return false unless @beeper.present?

    Service.find_by(leg_ope: @beeper)
  end

  def exists_reserve_error
    Import.last.wrong_reserves.include? @reserve
  end

end
