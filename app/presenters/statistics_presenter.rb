class StatisticsPresenter

  def initialize(params:, current_user: nil)
    @params = params
    @user   = current_user
  end

  def filter
    StatisticsFilter.new(filter_params)
  end

  def payment_groups
    @payment_groups ||= filter.call
  end

  def amount_by_operators
    operators.sort_by { |key, value| value[:name] }.to_h
  end

  def quantity_by_operators
    grouped_operators
  end

  def amount_by_bank
    accounts.sort_by { |key, value| value[:name] }.to_h
  end

  def quantity_by_bank
    accounts.sort_by { |key, value| value[:quantity] }.reverse.to_h
  end

  def ars_payment_groups
    @ars_payment_groups ||= payment_groups.select do |each|
      each.currency_for_statistics == 'P'
    end
  end

  def usd_payment_groups
    @usd_payment_groups ||= payment_groups.select do |each|
      each.currency_for_statistics == 'D'
    end
  end

  def eur_payment_groups
    @eur_payment_groups ||= payment_groups.select do |each|
      each.currency_for_statistics == 'E'
    end
  end

  def total_ars
    @total_ars ||= ars_payment_groups.inject(0) do |sum, each|
      sum + each.total_for_statistics
    end
  end

  def total_usd
    @total_usd ||= usd_payment_groups.inject(0) do |sum, each|
      sum + each.total_for_statistics
    end
  end

  def total_eur
    @total_eur ||= eur_payment_groups.inject(0) do |sum, each|
      sum + each.total_for_statistics
    end
  end

  def total_ars_by_month
    @total_ars_by_month ||= _total_by_month(ars_payment_groups)
  end

  def total_usd_by_month
    @total_usd_by_month ||= _total_by_month(usd_payment_groups)
  end

  def total_eur_by_month
    @total_eur_by_month ||= _total_by_month(eur_payment_groups)
  end

  def usd_cotization
    @usd_cotization ||= _usd_cotization(usd_payment_groups)
  end

  private

  def filter_params
    if @params[:statistics_filter]
      @params.
        require(:statistics_filter).
        permit(:operator_category, :from, :to, :from_2, :to_2, :order_by, :order_as)
    else
      {from: Date.today - 30.days}
    end
  end

  def operators
    return @operators unless @operators.nil?

    @operators = {}

    payment_groups.each do |each|

      key   = each.operator_aptour_id
      total = each.total_for_statistics

      @operators[key] = {
        quantity: 0,
        ars:      0,
        usd:      0,
        eur:      0,
        name:     each.operator_name
      } if @operators[key].nil?

      @operators[key][:quantity] += 1

      case each.currency_for_statistics
      when 'P' then @operators[key][:ars] += total
      when 'D' then @operators[key][:usd] += total
      when 'E' then @operators[key][:eur] += total
      end
    end

    @operators
  end

  def grouped_operators
    return @grouped_operators unless @grouped.nil?

    @grouped_operators = operators.
      select  { |key, value| value[:quantity] > 1 }.
      sort_by { |key, value| value[:quantity] }.reverse.to_h

    @grouped_operators[0] = {
      name:     'Otros con sólo un pago',
      quantity: operators.
        select { |key, value| value[:quantity] == 1 }.
        size
    }

    @grouped_operators
  end

  def accounts
    return @accounts unless @accounts.nil?

    @accounts = {}

    payment_groups.each do |each|
      next if each.payment.payment_method.nil?

      key     = each.payment.payment_method
      total   = each.total_for_statistics
      account = each.payment.account

      @accounts[key] = {
        quantity: 0,
        ars:      0,
        usd:      0,
        eur:      0,
        name:     account ? account.name : '-'
      } if @accounts[key].nil?

      @accounts[key][:quantity] += 1

      case each.currency_for_statistics
      when 'P' then @accounts[key][:ars] += total
      when 'D' then @accounts[key][:usd] += total
      when 'E' then @accounts[key][:eur] += total
      end
    end

    @accounts
  end

  def _total_by_month(records)
    result = {}

    records.each do |each|

      month = each.sent_date.month
      year  = each.sent_date.year
      key   = month.to_s + "-" + year.to_s

      result[key] = {
        total:    0,
        quantity: 0,
        month:    month,
        year:     year,
        label:    key
      } if result[key].nil?

      result[key][:total]    += each.total_for_statistics
      result[key][:quantity] += 1

    end

    result.values.each { |each| each[:total] = each[:total].round }
    result.values.sort do |a, b|
      [a[:year], a[:month]] <=> [b[:year], b[:month]]
    end

  end

  def _usd_cotization(records)
    return 1 if records.size.zero?

    total = records.inject(0) do |sum,each|
      sum + each.payment.cotization.to_f
    end

    total / records.size
  end

end
