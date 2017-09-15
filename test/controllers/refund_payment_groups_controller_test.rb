require 'test_helper'

class RefundPaymentGroupsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user   = profiles(:alfonsin)
    @payment_group = payment_groups(:payment_group_six)

    WebMock.stub_request(:get, /.*current/).
      to_return(:status => 200, :body => "", :headers => {})
    WebMock.stub_request(:get, /.*all_accounts/).
      to_return(:status => 200, :body => File.new('test/api_mocks/accounts.json').read, :headers => {'Content-Type' => 'application/json'})
    WebMock.stub_request(:get, /.*subaccounts/).
      to_return(:status => 200, :body => File.new('test/api_mocks/subaccounts.json').read, :headers => {'Content-Type' => 'application/json'})
  end

  test 'should change payment_group status to in_process' do
    payments_amount = Payment.count

    put :processed,
      id: @payment_group.id,
      type: "RefundPaymentGroup",
      national_payment_group: {
        cotization: 15.7
      }

    payment = @payment_group.payment

    assert_response :success
    assert_not_nil  payment
    assert          @payment_group.reload.in_process?
    assert_equal    payments_amount + 1, Payment.count
    assert_equal    payment, Payment.last
    assert_equal    @payment_group.total, payment.total_debt
  end

  test 'should show refund' do
    get :show,
      id: payment_groups(:payment_group_seven).id,
      type: 'RefundPaymentGroup'

    assert_response :success
  end

end
