require 'test_helper'
require 'pp'

class OperatorsPositiveBalancesFilterTest < ActiveSupport::TestCase

  test 'should return all operators' do
    operators = Operator.not_guardias
    records   = OperatorsPositiveBalancesFilter.new.call

    assert_equal operators.count, records.count
    assert_equal operators.map(&:attributes), records.map(&:attributes)
  end

  test 'should return operators form a category' do
    Operator.categories.each do |key, value|
      next if key == 'undefined'

      operators = Operator.where(category: value)
      records   = OperatorsPositiveBalancesFilter.new(
        {category: key}
      ).call

      assert_equal operators.count, records.count
      assert_equal operators.map(&:attributes),
        records.map(&:attributes)
    end
  end

end
