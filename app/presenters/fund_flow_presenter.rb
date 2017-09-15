class FundFlowPresenter

  def initialize(params)
    @params = params
  end

  def filter
    @filter ||= FundFlowFilter.new(filter_params)
  end

  def by_day
    return @by_day unless @by_day.nil?

    @by_day = {}

    generate :default
    complete :default

    @by_day
  end

  def all_by_day
    return @all_by_day unless @all_by_day.nil?

    @all_by_day = {}

    generate :all
    complete :all

    @all_by_day
  end

  def operator
    @operator ||= Operator.find_by(aptour_id: filter.operator_aptour_id)
  end

  private

  def filter_params
    if @params[:fund_flow_filter]
      @params.
        require(:fund_flow_filter).
        permit(:from, :to, :operator_category, :operator_cc, :operator_aptour_id)
    end
  end

  def service_registers
    @service_registers ||= filter.call(false)
  end

  def all_service_registers
    @all_service_registers ||= filter.call(true)
  end

  def generate(mode)
    (filter.from..filter.to).map(&:itself).each do |date|
      key = "#{date.day}-#{date.month}-#{date.year}"

      default_values = {
        sum_ars:     0.0,
        sum_usd:     0.0,
        sum_usd_nat: 0.0,
        sum_usd_int: 0.0,
        date:        date,
        label:       "#{Const::WEEK_DAYS[date.wday - 1]} #{date.day}/#{date.month}"
      }

      if mode == :all
        @all_by_day[key] = default_values
      else
        @by_day[key] = default_values
      end
    end
  end

  def complete(mode)
    records = mode == :default ? service_registers : all_service_registers

    records.each do |service|
      next unless valid_service_register? service

      date = service.fec_pag.nil? ? service.fec_sal : service.fec_pag
      key  = "#{date.day}-#{date.month}-#{date.year}"

      update(mode, key, service)
    end
  end

  def valid_service_register?(record)
    return true if record.fec_pag.nil? ||
      record.ps == 'S'

    record.ps == 'P' &&
      filter.to.end_of_day         >= record.fec_pag &&
      filter.from.beginning_of_day <= record.fec_pag
  end

  def update(mode, key, service)
    if mode == :all
      @all_by_day[key][:sum_ars] += service.dif.to_f
      @all_by_day[key][:sum_usd] += service.difus.to_f

      if service.national?
        @all_by_day[key][:sum_usd_nat] += service.difus.to_f
      elsif service.international?
        @all_by_day[key][:sum_usd_int] += service.difus.to_f
      end
    else
      @by_day[key][:sum_ars] += service.dif.to_f
      @by_day[key][:sum_usd] += service.difus.to_f

      if service.national?
        @by_day[key][:sum_usd_nat] += service.difus.to_f
      elsif service.international?
        @by_day[key][:sum_usd_int] += service.difus.to_f
      end
    end
  end

end
