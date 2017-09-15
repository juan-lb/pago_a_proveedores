require 'test_helper'

class PaymentGroupReportsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)

    @payment_group = payment_groups(:payment_group_two)
    @report        = @payment_group.payment_group_report
    @params        = {
      swift: 'New SWIFT',
      note:  'Notas'
    }
  end

  test 'should get show' do
    get :show, id: @payment_group.id

    assert_response :success
    assert_not_nil assigns(:payment_group)
    assert_not_nil assigns(:report)
  end

  test 'should update a report' do
    xhr :post, :update, id: @report.id, payment_group_report: @params

    assert_response :success
  end

  test 'should export PDF' do
    get :export,
      id: @payment_group.id,
      payment_group_report: @params,
      format: :pdf

    assert_response :success
  end

end
