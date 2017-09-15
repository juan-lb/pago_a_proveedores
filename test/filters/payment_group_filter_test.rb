require 'test_helper'
require 'pp'

class PaymentGroupFilterTest < ActiveSupport::TestCase

  def setup
    @user = profiles(:alfonsin)
  end

  test 'should return all payment_groups' do
    res = PaymentGroupFilter.new(query: {}, user: @user, page: 1).call

    payment_groups = PaymentGroup.where.not(type: 'RefundPaymentGroup')

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return all payment_groups of user operator_category' do
    res = PaymentGroupFilter.new(query: nil, user: @user, page: 1).call

    payment_groups =
      if @user.operator_category == 'national'
        PaymentGroup.from_national_operator
      elsif @user.operator_category == 'international'
        PaymentGroup.from_international_operator
      end
    payment_groups = payment_groups.where.not(type: 'RefundPaymentGroup')

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return payment_groups of an operator_category' do
    query = {
      operator_category: 'international'
    }

    res = PaymentGroupFilter.new(query: query, user: @user, page: 1).call

    payment_groups = PaymentGroup.
      from_international_operator.
      where.not(type: 'RefundPaymentGroup')

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return payment_groups from an operator' do
    query = {
      operator_id: operators(:national).aptour_id
    }

    res = PaymentGroupFilter.new(query: query, user: @user, page: 1).call

    payment_groups = PaymentGroup.
      where(operator_aptour_id: operators(:national).aptour_id)

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return payment_groups from a date rank' do
    query = {
      from: '2017-05-04',
      to:   '2017-05-06'
    }

    res  = PaymentGroupFilter.new(query: query, user: @user, page: 1).call
    from = query[:from].to_datetime.beginning_of_day
    to   = query[:to].to_datetime.end_of_day

    payment_groups = PaymentGroup.
      where.not(type: 'RefundPaymentGroup').
      where('updated_at >= ? and updated_at <= ?', from, to)

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return payment_groups from a reserve' do
    query = {
      reserve: reserves(:reserve_two).reserve_id
    }

    res = PaymentGroupFilter.new(query: query, user: @user, page: 1).call

    payment_groups = PaymentGroup.
      joins(:services).
      where.not(type: 'RefundPaymentGroup').
      where('reserve_id = ?', "#{query[:reserve]}").
      distinct

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return payment_groups from a beeper' do
    query = {
      leg_ope: services(:service_one).leg_ope
    }

    res = PaymentGroupFilter.new(query: query, user: @user, page: 1).call

    payment_groups = PaymentGroup.
      joins(:services).
      where.not(type: 'RefundPaymentGroup').
      where('leg_ope LIKE ?', "%#{query[:leg_ope]}%").
      distinct

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return payment_groups from a passenger' do
    query = {
      passenger: services(:service_one).viajeroresponsable
    }

    res = PaymentGroupFilter.new(query: query, user: @user, page: 1).call

    payment_groups = PaymentGroup.
      joins(:services).
      where.not(type: 'RefundPaymentGroup').
      where('viajeroresponsable LIKE ?', "%#{query[:passenger]}%").
      distinct

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

  test 'should return payment_groups from some sellers' do
    query = {
      sellers:
        [users(:user_one).aptour_id, users(:user_two).aptour_id]
    }

    res = PaymentGroupFilter.new(query: query, user: @user, page: 1).call

    payment_groups = PaymentGroup.
      joins(:services).
      where.not(type: 'RefundPaymentGroup').
      where('services.seller_aptour_id' => query[:sellers]).
      distinct

    assert_equal payment_groups.draft.count,      res.draft.count
    assert_equal payment_groups.in_process.count, res.in_process.count
    assert_equal payment_groups.sent.count,       res.sent.count
    assert_equal payment_groups.closed.count,     res.closed.count

    assert_equal payment_groups.draft.map(&:attributes),
      res.draft.map(&:attributes)
    assert_equal payment_groups.in_process.map(&:attributes),
      res.in_process.map(&:attributes)
    assert_equal payment_groups.sent.map(&:attributes),
      res.sent.map(&:attributes)
    assert_equal payment_groups.closed.map(&:attributes),
      res.closed.map(&:attributes)
  end

end
