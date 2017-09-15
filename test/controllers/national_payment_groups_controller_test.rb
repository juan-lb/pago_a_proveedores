require 'test_helper'

class NationalPaymentGroupsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user   = profiles(:alfonsin)
    @payment_group = payment_groups(:payment_group_one)

    WebMock.stub_request(:get, /.*current/).
      to_return(:status => 200, :body => "", :headers => {})
    WebMock.stub_request(:get, /.*all_accounts/).
      to_return(:status => 200, :body => File.new('test/api_mocks/accounts.json').read, :headers => {'Content-Type' => 'application/json'})
  end

  test 'should change payment_group status to SENT' do
    WebMock.stub_request(:post, /.*confirmation_codes/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/confirmation_codes.json').read,
        headers: {'Content-Type' => 'application/json'}
    )

    payments_amount = Payment.count

    put :sent,
      id: @payment_group.id,
      type: "NationalPaymentGroup",
      national_payment_group: {
        cotization: 15.3
      }

    payment = @payment_group.payment

    assert_response :success
    assert_not_nil  payment
    assert          @payment_group.reload.sent?
    assert_equal    payments_amount + 1, Payment.count
    assert_equal    payment, Payment.last
    assert_equal    @payment_group.total, payment.total_debt

  end

  test 'should show credit' do
    get :show,
      id: payment_groups(:payment_group_two).id,
      type: 'NationalPaymentGroup'

    assert_response :success
  end

end
