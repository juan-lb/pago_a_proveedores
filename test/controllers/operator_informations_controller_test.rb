require 'test_helper'

class OperatorInformationsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)
  end

  test 'should get new' do
    xhr :get, :new, operator_aptour_id: 3

    assert_response :success
    assert_not_nil  assigns(:operator_information)
  end

end
