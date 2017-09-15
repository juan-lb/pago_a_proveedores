class LocatorsUpdaterTest < ActiveSupport::TestCase

  def setup
    @payment = payment_groups(:payment_group_one)

    WebMock.stub_request(:post, /.*confirmation_codes/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/confirmation_codes.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

  test 'should update services locators' do
    updater  = LocatorsUpdater.new(payment_group: @payment)
    services = @payment.services.pluck(:id, :leg_ope)

    assert updater.call

    @payment.reload

    services.each do |service|
      assert_not_equal service[1],
        @payment.services.find(service[0]).leg_ope
    end
  end

end
