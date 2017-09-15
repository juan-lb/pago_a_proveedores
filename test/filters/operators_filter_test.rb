require 'test_helper'
require 'pp'

class OperatorsFilterTest < ActiveSupport::TestCase

  test 'should return all operators' do
    filter  = OperatorsFilter.new
    records = filter.call

    assert_nil filter.name
    assert_nil filter.category
    assert_equal Operator.not_guardias.map(&:attributes),
      records.map(&:attributes)
  end

  test 'should return operators from a category' do
    Profile::OPERATOR_CATEGORY.each do |category|
      params  = {category: category}
      filter  = OperatorsFilter.new params
      records = filter.call

      assert_nil filter.name
      assert_equal category, filter.category
      assert_equal Operator.not_guardias.send(category).map(&:attributes),
        records.map(&:attributes)
    end
  end

  test 'should return operators by name' do
    params  = {name: 'Operator'}
    filter  = OperatorsFilter.new params
    records = filter.call

    assert_nil filter.category
    assert_equal params[:name], filter.name
    assert_equal Operator.not_guardias.search(params[:name]).map(&:attributes),
      records.map(&:attributes)
  end

end
