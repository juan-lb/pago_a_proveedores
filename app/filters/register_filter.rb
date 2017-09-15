class RegisterFilter
  include ActiveModel::Model

  attr_accessor :operator_category, :operator_id, :from, :to, :status, :status_service, :order_by, :order_as, :beeper, :fec_type, :traveller, :credits_tab, :reserve, :register_ids, :consider_passengers

  ORDER_BY  = %w(próxima reserva depositado)
  ORDER_AS  = %w(ascendente descendente)

  FEC_TYPES = {
    'Próxima' => 'near_expiring_date',
    'In'      => 'fec_sal',
    'Out'     => 'fec_out',
    'Pago'    => 'fec_pag',
    'Seña'    => 'fec_sen'
  }

  ORDER_HASH = {
    "próxima"     => 'near_expiring_date',
    "reserva"     => 'id_res',
    "depositado"  => '(paid_in_cents + paid_usd_in_cents)',
    "ascendente"  => 'ASC',
    "descendente" => 'DESC'
  }

  def initialize(*args)
    super
    @fec_type ||= FEC_TYPES.values.first
    @consider_passengers = consider_passengers.to_i == 1
  end

  def debits
    registers = ServiceRegister.
      not_marked.
      from_operator(operator_id).
      with_debt

    registers = filter_registers registers

    if order_by == 'depositado'
      registers = registers.joins(:reserve)
    end

    registers = registers.
      order(order_criteria).
      includes(reserve: [:agency])
  end

  def credits
    ServiceRegister.
      not_marked.
      from_operator(operator_id).
      with_cred.
      includes(reserve: [:agency])
  end

  def operators
    operator_id.nil? ? {} : [[Operator.find_by(aptour_id: operator_id).name, operator_id]]
  end

  def selected_operator
    operator_id.nil? ? {} : {selected: operator_id}
  end

  private

  def filter_registers(registers)
    registers = registers.where(
      "#{fec_type} >= ?", from.to_date
    ) if from.present?

    registers = registers.where(
      "#{fec_type} <= ?", to.to_date
    ) if to.present?

    registers = registers.where(
      status_service: status_service
    ) if status_service.present?

    registers = filter_by_beeper(registers) if beeper.present?

    registers = registers.where(
      id_res: reserve.strip
    ) if reserve.present?

    if traveller.present?
      if consider_passengers
        registers = filter_by_paxs(registers)
      else
        registers = registers.where(
          'viajeroresponsable LIKE ?', "%#{traveller.strip}%"
        )
      end
    end

    registers
  end

  def filter_by_beeper(registers)
    con = Connection.new(ENV['MO_SERVICES_URL'])
    res = con.get_reserves_by_locator(beeper, operator_id)

    return registers unless res.status == 200

    registers.where(
      id_res: res.body['aptour_reserve_ids']
    )
  end

  def filter_by_paxs(registers)
    con = Connection.new(ENV['APTOUR_URL'])
    res = con.get_paxs_by_name traveller

    return registers unless res.status == 200

    reserves = res.body.map { |each| each['id_res'] }.uniq
    registers.where(id_res: reserves)
  end

  def order_criteria
    if @order_by == 'depositado'
      order_by = "(reserves.paid_in_cents + reserves.paid_usd_in_cents*#{Cotizator.new.usd_cotization})"
    else
      order_by = @order_by.nil? ? "" : ORDER_HASH[@order_by] + " "
    end
    order_as = @order_as.nil? ? "" : ORDER_HASH[@order_as]

    order_by + order_as
  end

end
