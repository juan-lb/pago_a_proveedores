class ComingEntriesManager

  include ActiveModel::Model

  attr_accessor :days, :operator_category, :only_without_cc, :min_ars, :min_usd, :operators

  def initialize(days:, operator_category:, only_without_cc: 1, min_ars: 500, min_usd: 20)
    @days              = days.to_i
    @operator_category = operator_category
    @only_without_cc   = (only_without_cc.to_i == 1)
    @min_ars           = min_ars.to_f
    @min_usd           = min_usd.to_f
    @operators         = _operators
  end

  private

  def _operators
    service_registers = registers
    return [] unless service_registers.any?

    service_registers = service_registers.
      select(:id, :id_ope, :nom_ope, :moneda, :dif_in_cents, :difus_in_cents)

    operators_hash = service_registers.group_by(&:id_ope)

    @coming_entries = operators_hash.map do |id, services|
      moneda = services.first.currency_symbol
      total  = services.map { |sr| sr.service_dif.to_f }.sum.round(2)

      next unless total_in_range? moneda, total

      {
        id:            id,
        nom_ope:       services.first.nom_ope,
        moneda:        moneda,
        total:         total,
        registers_ids: services.collect(&:id)
      }
    end

    @coming_entries = @coming_entries.
      compact.
      sort_by { |o| o[:total] }.
      reverse
  end

  def registers
    service_registers = ServiceRegister.
      not_marked.
      not_guardias.
      where("fec_sal <= ?", @days.days.from_now.to_date).
      with_debt

    service_registers = service_registers.
      ope_without_cc if only_without_cc

    if operator_category == 'national'
      service_registers.from_national_operator
    else
      service_registers.from_international_operator
    end

  end

  def total_in_range?(currency, total)
    (currency == 'AR$' && total > min_ars) ||
    (currency == 'U$D' && total > min_usd)
  end

end
