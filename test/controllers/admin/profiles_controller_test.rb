require 'test_helper'

class Admin::ProfilesControllerTest < ActionController::TestCase

  def setup
    authenticate

    @profile = profiles(:alfonsin)
    @profile_new_data = {
      role: 'user',
      operator_category: 'international',
      report_message: 'New Message'
    }
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil  assigns(:profiles)
    assert_equal    Profile.count, assigns(:profiles).send(:count)
  end

  test 'should edit profile' do
    get :edit, id: @profile

    assert_response :success
    assert_equal    @profile, assigns(:profile)
  end

  test "should update user" do
    assert_record_differences(@profile, @profile_new_data) do
      put :update, id: @profile.id, profile: @profile_new_data
    end

    assert_response :found
    assert_redirected_to admin_profiles_path
  end

  test 'should destroy user' do
    delete :destroy, id: profiles(:anakin)

    assert_response :found
    assert_redirected_to admin_profiles_path
  end

end
