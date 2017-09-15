require 'test_helper'
require 'pp'

class RegisterFilterTest < ActiveSupport::TestCase

  def setup
    @params = {
      operator_id:       operators(:national).aptour_id,
      operator_category: 1
    }
  end

  test "should return empty debits and credits when no operator" do
    register_filter = RegisterFilter.new(
      {operator_category: 1}
    )

    assert register_filter.credits.empty?
    assert register_filter.debits.empty?
  end

  test "should return empty debits and credits when operator without services_registers" do
    register_filter = RegisterFilter.new(
      {
        operator_id: 3,
        operator_category: 2
      }
    )

    assert_empty register_filter.credits
    assert_empty register_filter.debits
  end

  test "should return all service registers" do
    register_filter = RegisterFilter.new(@params)

    debits = ServiceRegister.
        from_operator(operators(:national).aptour_id).
        not_marked.
        confirmed.
        with_debt
    credits = ServiceRegister.
        from_operator(operators(:national).aptour_id).
        not_marked.
        confirmed.
        with_cred

    assert_equal debits.count, register_filter.debits.size
    assert_equal credits.count, register_filter.credits.size

    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
    assert_equal credits.map(&:attributes),
      register_filter.credits.map(&:attributes)
  end

  test "should return all credits no matter what params" do
    credits = ServiceRegister.with_cred

    register_filter = RegisterFilter.new(
      @params.merge({
        fec_type: 'fec_sen',
        from:     '20/09/2016',
        to:       '23/09/2016'
      })
    )

    assert_equal credits.count, register_filter.credits.size
    assert_equal credits.map(&:attributes),
      register_filter.credits.map(&:attributes)
  end

  test "should filter services by 'fecha de entrada/in'" do
    from   = '20/09/2016'
    to     = '23/09/2016'
    debits = ServiceRegister.
      from_operator(operators(:national).aptour_id).
      not_marked.
      confirmed.
      with_debt.
      fec_type_between_dates('fec_sal', from.to_date, to.to_date)

    register_filter = RegisterFilter.new(
      @params.merge({
        fec_type: 'fec_sal',
        from:     from,
        to:       to
      })
    )

    assert_equal debits.count, register_filter.debits.size
    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
  end

  test "should filter services by 'fecha de salida/out'" do
    from   = '19/09/2016'
    to     = '19/09/2016'
    debits = ServiceRegister.
      from_operator(operators(:national).aptour_id).
      not_marked.
      confirmed.
      with_debt.
      fec_type_between_dates('fec_out', from.to_date, to.to_date)

    register_filter = RegisterFilter.new(
      @params.merge({
        fec_type: 'fec_out',
        from:     from,
        to:       to
      })
    )

    assert_equal debits.count, register_filter.debits.size
    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
  end

  test "should filter services by 'fecha de pago'" do
    from   = '20/09/2016'
    to     = '22/09/2016'
    debits = ServiceRegister.
      from_operator(operators(:national).aptour_id).
      not_marked.
      confirmed.
      with_debt.
      fec_type_between_dates('fec_pag', from.to_date, to.to_date)

    register_filter = RegisterFilter.new(
      @params.merge({
        fec_type: 'fec_pag',
        from:     from,
        to:       to
      })
    )

    assert_equal debits.count, register_filter.debits.size
    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
  end

  test "should filter services by status_service" do
    debits = ServiceRegister.
      from_operator(operators(:national).aptour_id).
      not_marked.
      confirmed.
      with_debt

    params = @params.merge({status_service: 1})
    register_filter = RegisterFilter.new(params)

    assert_equal debits.count, register_filter.debits.size
    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
  end

  test "should filter services by beeper/leg_ope" do
    WebMock.stub_request(:get, /.*find_by_confirmation_code/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/services_by_locator.json').read,
        headers: {'Content-Type' => 'application/json'}
    )

    params = @params.merge({beeper: 'leg_ope_dollars_debit'})
    register_filter = RegisterFilter.new(params)
    reserves = JSON.parse(File.new('test/api_mocks/services_by_locator.json').read)['aptour_reserve_ids']

    debits = ServiceRegister.
      from_operator(operators(:national).aptour_id).
      not_marked.
      confirmed.
      with_debt.
      where(id_res: reserves)


    assert_equal debits.count, register_filter.debits.size
    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
  end

  test "should filter services by 'viajeroresponsable/traveller'" do
    debits = ServiceRegister.
      from_operator(operators(:national).aptour_id).
      not_marked.
      confirmed.
      with_debt.
      where(viajeroresponsable: 'Christian Castro')

    params = @params.merge({traveller: 'Christian Castro'})
    register_filter = RegisterFilter.new(params)

    assert_equal debits.count, register_filter.debits.size
    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
  end

  test "should filter services by 'reserve'" do
    reserve  = reserves(:reserve_three)
    params   = @params.merge({reserve: reserve.reserve_id.to_s})
    register_filter = RegisterFilter.new(params)

    debits = ServiceRegister.
      from_operator(operators(:national).aptour_id).
      not_marked.
      confirmed.
      with_debt.
      where(id_res: reserve.reserve_id.to_s)

    assert_equal debits.count, register_filter.debits.size
    assert_equal debits.map(&:attributes),
      register_filter.debits.map(&:attributes)
  end

end
