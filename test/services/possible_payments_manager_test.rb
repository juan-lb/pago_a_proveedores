require 'test_helper'

class PossiblePaymentsManagerTest < ActiveSupport::TestCase

  def setup
    @params = {
      operator_category: 'national',
      fec_type:          'fec_sal',
      from:              '2016-08-20',
      to:                '2016-10-20',
      future_fec_out:    '0',
      only_without_cc:   '0'
    }
  end

  test "should filter services matching fec_sal and national category" do
    manager = PossiblePaymentsManager.new(@params)

    assert_empty     manager.ars_operators
    assert_not_empty manager.usd_operators
  end

  test "should filter services matching fec_sal and international category" do
    params = @params
    params.merge!({operator_category: 'international'})

    manager = PossiblePaymentsManager.new(params)

    assert_empty     manager.ars_operators
    assert_not_empty manager.usd_operators
  end

  test "should not filter services if date range not matches" do
    params = {operator_category: 'national', future_fec_out: 0, fec_type: 'fec_sal', from: "2016-10-20", to: "2016-10-20"}
    manager = PossiblePaymentsManager.new(params)

    assert_empty manager.ars_operators
    assert_empty manager.usd_operators
  end

  test "should filter services matching fec_out" do
    params = @params
    params.merge!({from: '2016-08-19', to: '2016-10-19', fec_type: 'fec_out'})
    manager = PossiblePaymentsManager.new(params)

    assert_empty     manager.ars_operators
    assert_not_empty manager.usd_operators
  end

  test "should filter services matching fec_pag" do
    params = @params
    params.merge!({from: '2016-08-22', to: '2016-10-22', fec_type: 'fec_pag'})
    manager = PossiblePaymentsManager.new(params)

    assert_empty     manager.ars_operators
    assert_not_empty manager.usd_operators
  end

  test "should exclude services when future_fec_out is true" do
    params = @params
    params.merge!({future_fec_out: 1})
    manager = PossiblePaymentsManager.new(params)

    assert_empty manager.ars_operators
    assert_empty manager.usd_operators
  end

end
