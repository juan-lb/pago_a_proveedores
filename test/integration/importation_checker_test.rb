require 'test_helper'

class ImportationCheckerTest < ActionDispatch::IntegrationTest

  def setup
    login(:alfonsin)
  end

  test "does not redirect to running importation page if no importation is running" do
    get root_path

    assert_response :success
  end

  test "redirects to running importation page if an importation is running" do
    Setting.start_importation

    get root_path

    assert_redirected_to importation_running_imports_path
    follow_redirect!
    assert_response :service_unavailable
  end

  test "redirects away from running importation page when an importation is not running" do
    skip

    get importation_running_imports_path

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

end

