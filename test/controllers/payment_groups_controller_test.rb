require 'test_helper'

class PaymentGroupsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:presenter)
  end

  test 'should destroy a payment_group' do
    payment_groups_amount = PaymentGroup.count

    delete :destroy,
      id: payment_groups(:payment_group_one).id,
      format: :js

    assert_response :success
    assert_equal(PaymentGroup.count, payment_groups_amount - 1)
    assert_not_nil assigns(:operator_aptour_id)
    assert_not_nil assigns(:register_ids)
    assert_equal 2, assigns(:register_ids).size
  end

  test 'should generate payment_group report' do
    get :report, id: payment_groups(:payment_group_two).id

    assert_response :success
    assert_not_nil assigns(:report)
  end

  test 'should export to excel' do
    get :export_to_excel,
      id: payment_groups(:payment_group_one).id,
      in_euros: true,
      format: :xlsx

    assert_response :success
  end

  test 'should get report form' do
    xhr :get, :payment_report_form,
      id: payment_groups(:payment_group_one)

    assert_response :success
  end

  test 'should send a report' do
    WebMock.stub_request(:post, /.*send-template.json/).
      to_return(:status => 200, :body => {'key' => 'test'}.to_json, :headers => {})

    post :send_payment_report,
      payment_report: {
        to:      "[\"bruce@wayne.com\",\"lucas.hourquebie@snappler.com\"]",
        sender:  'Bruce Wayne',
        message: 'Test',
        swift: 'SWIFT de ejemplo'
      },
      id: payment_groups(:payment_group_two),
      format: :js

    assert_response :success
    assert_not_nil payment_group_reports(:report).last_email_date
  end

  test 'should update services locators' do
    WebMock.stub_request(:post, /.*confirmation_codes/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/confirmation_codes.json').read,
        headers: {'Content-Type' => 'application/json'}
    )

    payment  = payment_groups(:payment_group_one)
    services = payment.services.pluck(:id, :leg_ope)

    post :update_locators, id: payment.id

    payment.reload

    assert_response :redirect
    assert_redirected_to report_payment_group_path(payment)

    services.each do |service|
      assert_not_equal service[1],
        payment.services.find(service[0]).leg_ope
    end
  end

end
