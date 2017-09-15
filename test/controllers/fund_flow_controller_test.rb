class FundFlowControllerTest < ActionController::TestCase

  def setup
    authenticate
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:presenter)
    assert_not_nil assigns(:presenter).filter
    assert_equal Date.today, assigns(:presenter).filter.from
    assert_equal Date.today + 14.days, assigns(:presenter).filter.to
  end

  test 'should get index with date params' do
    params = {
      from: Date.tomorrow,
      to:   Date.tomorrow + 1.month
    }

    get :index, fund_flow_filter: params

    assert_response :success
    assert_not_nil assigns(:presenter)
    assert_not_nil assigns(:presenter).filter
    assert_equal params[:from], assigns(:presenter).filter.from
    assert_equal params[:to], assigns(:presenter).filter.to
  end

  test 'should get index with operator category' do
    Operator.categories.keys.each do |category|
      next if category == 'undefined'

      get :index, fund_flow_filter: {operator_category: category}

      assert_response :success
      assert_not_nil assigns(:presenter)
      assert_not_nil assigns(:presenter).filter
      assert_equal category, assigns(:presenter).filter.operator_category
    end
  end

  test 'should get index with operator_cc filter' do
    FundFlowFilter::OPERATOR_CC.values.each do |option|
      get :index, fund_flow_filter: {operator_cc: option}

      assert_response :success
      assert_not_nil assigns(:presenter)
      assert_not_nil assigns(:presenter).filter
      assert_equal option.to_s, assigns(:presenter).filter.operator_cc
    end
  end

  test 'should get operator' do
    operator = Operator.take

    xhr :get, :operator, fund_flow_filter: {operator_aptour_id: operator.aptour_id}

    assert_response :success
    assert_not_nil assigns(:presenter)
    assert_not_nil assigns(:presenter).filter
    assert_equal operator, assigns(:presenter).operator
    assert_equal operator.aptour_id,
      assigns(:presenter).filter.operator_aptour_id.to_i
  end

end
