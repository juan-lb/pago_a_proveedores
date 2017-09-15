class PayableManager

  include ActiveModel::Model

  attr_accessor :operator_category, :fec_type, :from, :to, :only_without_cc, :days

  def initialize(*args)
    super
    @fec_type        = fec_type.blank? ? 'fec_sal' : fec_type
    @from            = from.blank? ? Date.today : from.to_date
    @to              = to.blank? ? (Date.today + 2.days) : to.to_date
    @days            = days.nil? ? 3 : days.to_i
    @only_without_cc = only_without_cc.to_i == 1
  end

  def operators
    return @operators unless @operators.nil?

    @operators = {}
    @reserves  = {}

    register_reserve_paid
    process_draft_payments

    service_registers.each do |service|
      key     = service.operator_aptour_id
      reserve = service.id_res

      @operators[key] = {
        services:  [],
        aptour_id: service.operator_aptour_id,
        name:      service.nom_ope.strip,
        prepaid:   false,
        sum_ars:   0,
        sum_usd:   0
      } unless @operators[key]

      next unless valid_insertion?(
        service,
        @operators[key][:sum_ars],
        @operators[key][:sum_usd]
      )

      register_reserve reserve, key

      @operators[key][:services] << service
      @operators[key][:prepaid]  ||= service.prepaid?
      @operators[key][:sum_ars]  +=  service.dif.to_f
      @operators[key][:sum_usd]  +=  service.difus.to_f
    end

    add_repeated_reserves_to_operators

    @operators
  end

  def ars_operators
    @ars_operators ||= operators.values.
      select { |operator| operator[:sum_ars] > 0 }.
      sort   { |a, b| a[:total] <=> b[:total] }.
      reverse
  end

  def usd_operators
    @usd_operators ||= operators.values.
      select { |operator| operator[:sum_usd] > 0 }.
      sort   { |a, b| a[:total] <=> b[:total] }.
      reverse
  end

  def total_ars_operators
    ars_operators.sum { |each| each[:sum_ars] }
  end

  def total_usd_operators
    usd_operators.sum { |each| each[:sum_usd] }
  end

  def repeated_reserves
    @repeated_reserves ||= @reserves.
      select { |k, v| v[:quantity] > 1 }.
      map    { |k, v| v[:file_number] }
  end

  private

  def service_registers
    return @service_registers unless @service_registers.nil?

    @service_registers = ServiceRegister.
      not_marked.
      not_guardias.
      with_debt.
      fec_type_between_dates("#{fec_type}", from, to).
      order("#{fec_type} asc").
      includes(:reserve)

    @service_registers =
      if fec_type == 'fec_mix'
        @service_registers.confirmed
      else
        lower_date  = Date.today.beginning_of_day - days.days
        higher_date = Date.today.end_of_day + days.days

        @service_registers.
          confirmed_with_exception(fec_type, lower_date, higher_date)
      end

    if operator_category.present?
      @service_registers =
        if operator_category == 'national'
          @service_registers.from_national_operator
        else
          @service_registers.from_international_operator
        end
    end

    if only_without_cc
      @service_registers = @service_registers.ope_without_cc
    end

    @service_registers
  end

  def valid_insertion?(service, sum_ars, sum_usd)
    results = []
    file    = service.reserve
    reserve = @reserves_paid[file.reserve_id]

    paid =
      if reserve.nil?
        {ars: 0, usd: 0}
      else
        {ars: reserve['ars'], usd: reserve['usd']}
      end

    draft = @payments[file.reserve_id] || {ars: 0, usd: 0}

    if service.dif > 0
      results << ((service.dif + sum_ars) <= file.paid - paid[:ars] - draft[:ars])
    end

    if service.difus > 0
      results << ((service.difus + sum_usd) <= file.paid_usd - paid[:usd] - draft[:usd])
    end

    results.all?
  end

  def register_reserve(reserve, operator)
    if @reserves[reserve]
      unless @reserves[reserve][:operator].include? operator
        @reserves[reserve][:quantity] += 1
        @reserves[reserve][:operator] << operator
      end
    else
      @reserves[reserve] = {
        file_number: reserve,
        quantity:    1,
        operator:    [operator]
      }
    end
  end

  def register_reserve_paid
    return @reserves_paid = {} unless service_registers.any?

    con = Connection.new(ENV['APTOUR_URL'])
    ids = service_registers.map { |each| each.id_res }
    res = con.get_multiple_paid_to_operators(ids).body

    @reserves_paid = res.reduce({}) do |sum, each|
      sum.merge(each['file_number'] => each)
    end
  end

  def process_draft_payments
    @payments = {}

    PaymentGroup.draft.includes(services: [:reserve]).each do |payment|
      payment.services.each do |service|
        key = service.reserve_id
        next if key.nil?

        @payments[key] = {
          ars: 0,
          usd: 0
        } unless @payments[key]

        if service.currency == 'P'
          @payments[key][:ars] += service.amount
        elsif service.currency == 'D'
          @payments[key][:usd] += service.amount
        end
      end
    end
  end

  def add_repeated_reserves_to_operators
    @operators.each do |key, value|
      value[:repeated_reserves] = value[:services].map(&:id_res).uniq.
        select { |each| repeated_reserves.include? each }
    end
  end

end
