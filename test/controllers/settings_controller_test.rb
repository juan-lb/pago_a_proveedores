class SettingsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)
    @setting = settings(:basic)

    WebMock.stub_request(:get, /.*accounts/).
      to_return(:status => 200, :body => File.new('test/api_mocks/accounts.json').read, :headers => {'Content-Type' => 'application/json'})
  end

  test 'should get index' do
    get :index

    assert_response  :success
    assert_not_empty assigns(:api_accounts)
    assert_equal     Account.count, assigns(:accounts).count
    assert_equal     @setting, assigns(:setting)
  end

  test 'should update a setting' do
    params = {
      ig_limit:   '100',
      ig_aliquot: '3.0',
      ig_base:    '20',
      max_usd_credit_dif: '-3.0',
      max_ars_credit_dif: '-50.0'
    }

    xhr :get, :update,
      id:      @setting.id,
      setting: params

      @setting.reload

      assert_response :success

      assert_equal @setting.ig_base.to_f,    params[:ig_base].to_f
      assert_equal @setting.ig_limit.to_f,   params[:ig_limit].to_f
      assert_equal @setting.ig_aliquot.to_f, params[:ig_aliquot].to_f

      assert_equal @setting.max_usd_credit_dif.to_f,
        params[:max_usd_credit_dif].to_f
      assert_equal @setting.max_ars_credit_dif.to_f,
        params[:max_ars_credit_dif].to_f
  end

  test 'should get edit emails form' do
    ['operators_average', 'positive_balances'].each do |target|
      xhr :get, :edit_emails, id: @setting.id, target: target

      assert_response :success
    end
  end

end
