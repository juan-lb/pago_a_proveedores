require 'test_helper'

class RetentionTest < ActiveSupport::TestCase
  
  def setup
    @operator = operators(:national)
    @setting  = settings(:basic)
    @ig_retention = ig_retentions(:arba)
  end
  
  test "should be 0 when accumulated limit has not been exceeded" do
    retention = Retention.new.call(operator: @operator, total: 100)

    assert_equal 0, retention
  end

  test "should be calculated from the excess when accumulated limit has been exceeded" do
    retention = Retention.new.call(operator: @operator, total: 150)

    assert_equal 1, retention
  end
  
  test "should be calculated from the total when accumulated limit has been exceeded" do
    @ig_retention.update(accumulated: 100)
    retention = Retention.new.call(operator: @operator, total: 150)
    
    # El 2% de 150 es 3
    assert_equal 3, retention
  end
  
  test "should be 0 when limit has not been exceeded" do
    retention = Retention.new.call(operator: @operator, total: 100)

    assert_equal 0, retention
  end

  test "should be 0 when operator has no retention" do
    @operator.has_ig_retention = false
    retention = Retention.new.call(operator: @operator, total: 100)

    assert_equal 0, retention
  end
  
end