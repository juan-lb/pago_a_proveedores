require 'will_paginate/array'
class OperatorsPositiveBalancesPresenter

  def initialize(params:)
    @params  = params
    @setting = Setting.take
  end

  def filter
    @filter ||= OperatorsPositiveBalancesFilter.new(filter_params)
  end

  def operators_with_balances
    @operators_with_balances ||= with_balances.
      paginate(page: @params[:page], per_page: Const::PER_PAGE)
  end

  def operators_with_credits
    @with_credits ||= operators_with_balances.select do |operator|
      (operator[:ars] + operator[:usd]).positive?
    end
  end

  def ars_total
    with_balances.inject(0) { |sum, operator| sum + operator[:ars] }
  end

  def usd_total
    with_balances.inject(0) { |sum, operator| sum + operator[:usd] }
  end

  def operators
    @operators ||= filter.call
  end

  private

  def filter_params
    if @params[:operators_positive_balances_filter]
      @params.
        require(:operators_positive_balances_filter).
        permit(:category, :name)
    else
      {category: nil, name: nil }
    end
  end

  def with_balances
    @with_balances ||= operators.map do |operator|
      credits = operator_credits(operator)

      next if credits[:ars] <= @setting.min_ars_credit_report &&
        credits[:usd] <= @setting.min_usd_credit_report

      res = {
        id:       operator.aptour_id,
        name:     operator.name,
        category: operator.category.to_sym
      }.merge credits

      res
    end.compact
  end

  def operator_credits(operator)
    res = operator.service_registers.map do |reg|
      next if reg.difus_in_cents > 0 || reg.dif_in_cents > 0

      {
        ars: reg.dif,
        usd: reg.difus
      }
    end.compact

    {
      ars: res.inject(0) { |sum,each| sum + each[:ars] }.abs,
      usd: res.inject(0) { |sum,each| sum + each[:usd] }.abs
    }
  end

end
