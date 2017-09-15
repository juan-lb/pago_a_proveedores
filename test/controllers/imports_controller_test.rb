require 'test_helper'

class ImportsControllerTest < ActionController::TestCase

  def setup
    authenticate

    currency = profiles(:alfonsin)
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:imports)
    assert_equal Import.count, assigns(:imports).count
  end

  test 'should get load_all' do
    get :load_all

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'should get load' do
    get :load, operator_id: Operator.take.aptour_id

    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'should get importation_running' do
    get :importation_running

    assert_response :redirect
    assert_redirected_to root_path
  end

end
