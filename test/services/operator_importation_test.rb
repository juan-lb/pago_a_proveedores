require 'test_helper'

class OperatorImportationTest < ActiveSupport::TestCase

  def setup
    stub_api_requests
  end

  test "should import operators and delete old ones" do
    old_operators_count = Operator.count
    assert_not_equal 0, old_operators_count

    operators_count = JSON.
      parse(File.new('test/api_mocks/operators.json').read).
      size

    OperatorImportation.new.call
    assert_equal operators_count, Operator.count
  end

  test "should not import aerials" do
    assert_not_equal ApiOperator.all.count, ApiOperator.not_aerials,
      'api request has no aerials on response'

    OperatorImportation.new.call
    assert_equal ApiOperator.not_aerials.count, Operator.count
  end

  private

  def stub_api_requests
    stub_request(:get, /.*operators.*/).
    to_return(
      body:    File.new('test/api_mocks/operators.json').read,
      status:  200,
      headers: {'Content-Type' => 'application/json'}
    )

  end

end
