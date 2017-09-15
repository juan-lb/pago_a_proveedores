class PossiblePaymentsManager

  include ActiveModel::Model

  attr_accessor :operator_id, :fec_type, :from, :to, :operator_category, :only_without_cc, :future_fec_out, :currency, :statuses

  def initialize(*args)
    super
    @fec_type        = fec_type.blank? ? 'fec_pag' : fec_type
    @from            = from.blank? ? Date.today : from.to_date
    @to              = to.blank? ? 2.days.from_now.to_date : to.to_date
    @only_without_cc = @only_without_cc ? (@only_without_cc.to_i == 1) : 1
    @future_fec_out  = @future_fec_out ? (@future_fec_out.to_i == 1) : 1
    @statuses =
      if statuses
        statuses.delete_if(&:blank?).map(&:to_i)
      else
        []
      end
  end

  def operators
    return @operators if @operators

    @operators = {}

    service_registers.each do |service|
      next unless valid_service_register? service

      key = service.operator_aptour_id

      @operators[key] = {
        services:  [],
        aptour_id: service.operator_aptour_id,
        name:      service.nom_ope.strip,
        prepaid:   false,
        sum_ars:   0,
        sum_usd:   0
      } unless @operators[key]

      @operators[key][:services] <<  service
      @operators[key][:prepaid]  ||= service.prepaid?
      @operators[key][:sum_ars]  +=  service.dif.to_f
      @operators[key][:sum_usd]  +=  service.difus.to_f
    end

    @operators
  end

  def ars_operators
    @ars_operators ||= operators.values.select do |operator|
      operator[:sum_ars] > 0
    end
  end

  def usd_operators
    @usd_operators ||= operators.values.select do |operator|
      operator[:sum_usd] > 0
    end
  end

  def total_ars_operators
    ars_operators.sum { |each| each[:sum_ars] }
  end

  def total_usd_operators
    usd_operators.sum { |each| each[:sum_usd] }
  end

  def operators_list_options
    @operator_id.nil? ? {} : [[Operator.find_by(aptour_id: @operator_id).name, @operator_id]]
  end

  def selected_operator
    @operator_id.nil? ? {} : { selected: @operator_id }
  end

  private

  def service_registers
    return @service_registers unless @service_registers.nil?

    @service_registers = ServiceRegister.
      where(operator: filtered_operators).
      not_guardias.
      with_debt.
      joins(:operator).
      not_marked.
      fec_type_between_dates("#{fec_type}", from, to).
      order('nom_ope')

    if statuses.any?
      @service_registers = @service_registers.where(
        status_service: statuses
      )
    end

    @service_registers = @service_registers.where(
      'fec_out is NULL OR fec_out > ?',
      Time.zone.today
    ) if future_fec_out

    @service_registers
  end

  def current_operator
    Operator.find_by(aptour_id: operator_id)
  end

  def filtered_operators
    return [current_operator] unless operator_id.nil?

    operators = Operator.all
    operators = operators.where(has_current_account: false) if only_without_cc.present?
    operators = operators.where(category: Operator.categories[operator_category]) if operator_category.present?

    operators
  end

  def filter_by_currency(services)
    if @currency == 'ARS'
      services = services.where('dif_in_cents > 0')
    else
      services = services.where('difus_in_cents > 0')
    end
    services
  end

  def valid_service_register?(record)
    return true if record.fec_pag.nil? ||
      !['fec_mix', 'fec_sen'].include?(fec_type) ||
      record.ps == 'S'

    record.ps == 'P' &&
      to.end_of_day         >= record.fec_pag &&
      from.beginning_of_day <= record.fec_pag
  end

end
