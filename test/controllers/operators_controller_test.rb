class OperatorsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:presenter)
    assert_not_empty assigns(:presenter).operators
    assert_equal Operator.count, assigns(:presenter).operators.count
  end

  test 'should get index with filtering by name' do
    get :index, operators_filter: {name: 'Operator'}

    operators = Operator.where("name LIKE '%Operator%'")

    assert_response :success
    assert_not_nil assigns(:presenter)
    assert_not_empty assigns(:presenter).operators
    assert_equal operators.count, assigns(:presenter).operators.count
    assert_equal operators.map(&:attributes),
      assigns(:presenter).operators.map(&:attributes)
  end

  test 'should get index with filtering by category' do
    get :index, operators_filter: {category: 'international'}

    operators = Operator.international
    assert_response :success
    assert_not_nil assigns(:presenter)
    assert_not_empty assigns(:presenter).operators
    assert_equal operators.count, assigns(:presenter).operators.count
    assert_equal operators.map(&:attributes),
      assigns(:presenter).operators.map(&:attributes)
  end

  test 'should get positive balances' do
    get :positive_balances

    assert_response  :success
    assert_not_nil   assigns(:presenter)
    assert_not_empty assigns(:presenter).operators
    assert_not_empty assigns(:presenter).operators_with_balances
  end

  test 'should get positive balances with filtering by name' do
    get :positive_balances, operators_positive_balances_filter: {name: 'Operator'}

    operators = Operator.where("name LIKE '%Operator%'")
    assert_response :success
    assert_not_nil assigns(:presenter)
    assert_not_empty assigns(:presenter).operators
    assert_equal operators.count, assigns(:presenter).operators.count
    assert_equal operators.map(&:attributes),
      assigns(:presenter).operators.map(&:attributes)
  end

end
