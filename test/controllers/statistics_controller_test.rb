require 'test_helper'

class StatisticsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:presenter)
  end

  test 'should get report form' do
    xhr :get, :report_form, format: :js

    assert_response :success
  end

  test 'should export a report as pdf' do
    get :export,
      statistics_filter: {
        from: '01/01/2016',
        to:   '28/04/2017'
      },
      format: :pdf

    assert_response :success
  end

  test 'should export a report as excel' do
    get :export_excel,
      statistics_filter: {
        from: '01/01/2016',
        to:   '28/04/2017'
      },
      format: :xlsx

    assert_response :success
  end

  test 'should send a report' do
    WebMock.stub_request(:post, /.*send-template.json/).
      to_return(:status => 200, :body => {'key' => 'test'}.to_json, :headers => {})

    post :send_report,
      statistics_report: {
        to:      'lucas.hourquebie@snappler.com',
        message: 'Test'
      },
      filter_params: {
        from: '01/01/2016',
        to:   '28/04/2017'
      },
      format: :js

    assert_response :success
  end

end
