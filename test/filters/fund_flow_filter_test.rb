require 'test_helper'
require 'pp'

class FundFlowFilterTest < ActiveSupport::TestCase

  def setup
    @params = {
      from: '20/09/2016',
      to:   '23/09/2016'
    }
  end

  test 'should return service_registers from date rank' do
    res = FundFlowFilter.new(@params).call(false)

    from    = @params[:from].to_date
    to      = @params[:to].to_date
    records = ServiceRegister.
      not_marked.
      with_debt.
      where(date_query, from, to, from, to)

    assert_equal records.count, res.count
    assert_equal records.map(&:attributes), res.map(&:attributes)
  end

  test 'should return service_registers from an operator_category' do
    params = @params.merge({operator_category: 'international'})

    res = FundFlowFilter.new(params).call(false)

    from    = @params[:from].to_date
    to      = @params[:to].to_date
    records = ServiceRegister.
      not_marked.
      from_international_operator.
      with_debt.
      where(date_query, from, to, from, to)

    assert_equal records.count, res.count
    assert_equal records.map(&:attributes), res.map(&:attributes)
  end

  test 'should return service_registers from operators with cc' do
    params = @params.merge({operator_cc: 'with_cc'})

    res = FundFlowFilter.new(params).call(false)

    from    = @params[:from].to_date
    to      = @params[:to].to_date
    records = ServiceRegister.
      not_marked.
      ope_with_cc.
      with_debt.
      where(date_query, from, to, from, to)

    assert_equal records.count, res.count
    assert_equal records.map(&:attributes), res.map(&:attributes)
  end

  test 'should return service_registers from operators without cc' do
    params = @params.merge({operator_cc: 'without_cc'})

    res = FundFlowFilter.new(params).call(false)

    from = @params[:from].to_date
    to   = @params[:to].to_date

    records = ServiceRegister.
      not_marked.
      ope_without_cc.
      with_debt.
      where(date_query, from, to, from, to)

    assert_equal records.count, res.count
    assert_equal records.map(&:attributes), res.map(&:attributes)
  end

  test 'should return service_registers from an operator' do
    params = @params.merge({operator_aptour_id: operators(:national).aptour_id})

    res = FundFlowFilter.new(params).call(false)

    from = @params[:from].to_date
    to   = @params[:to].to_date

    records = ServiceRegister.
      not_marked.
      with_debt.
      where(date_query, from, to, from, to).
      where(operator_aptour_id: params[:operator_aptour_id])

    assert_equal records.count, res.count
    assert_equal records.map(&:attributes), res.map(&:attributes)
  end

  private

  def date_query
    "(fec_pag IS NOT NULL AND fec_pag >= ? AND fec_pag <= ?) OR (fec_pag IS NULL AND fec_sal >= ? AND fec_sal <= ?)"
  end

end
