require 'test_helper'
require 'pp'

class StatisticsFilterTest < ActiveSupport::TestCase

  def setup
    @params = {
      from: '2017-05-01',
      to:   '2018-05-01'
    }
  end

  test 'should return all payments' do
    filter = StatisticsFilter.new(@params)
    res    = filter.call

    records =  PaymentGroup.
      where(is_credit: false).
      where("status = 'Cargado' OR status = 'Enviado'")

    assert_not_empty res
    assert_equal records.count, res.count
    assert_equal records.map(&:attributes), res.map(&:attributes)
    assert_not filter.comparison_mode
  end

  test 'should return all payments from an operator_category' do
    params = @params.merge({
      operator_category: 'international',
    })

    filter = StatisticsFilter.new(params)
    res    = filter.call

    records = PaymentGroup.
      where(is_credit: false).
      where("status = 'Cargado' OR status = 'Enviado'").
      where(category: 2)

    assert_not_empty res
    assert_equal records.count, res.count
    assert_equal records.map(&:attributes), res.map(&:attributes)
    assert_not filter.comparison_mode
  end

  test 'should have comparison mode enabled' do
    params = @params.merge({
      to:     '2018-05-31',
      from_2: '2018-05-01',
      to_2:   '2017-05-31'
    })

    filter = StatisticsFilter.new(params)

    assert filter.comparison_mode
  end

end
