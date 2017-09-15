class AccountsControllerTest < ActionController::TestCase

  def setup
    authenticate

    current_user = profiles(:alfonsin)
    @account     = accounts(:account_one)

    WebMock.stub_request(:get, /.*account/).
      to_return(
        status:  200,
        body:    File.new('test/api_mocks/account.json').read,
        headers: {'Content-Type' => 'application/json'}
    )
  end

  test 'should create an account' do
    accounts_count = Account.count

    post :create, accounts: ['4']

    assert_response :found
    assert_redirected_to settings_path
    assert accounts_count + 1, Account.count
  end

  test 'should update an account' do
    xhr :put, :update, id: @account.id, account: account_params

    @account.reload

    assert_response :success
    assert_not_nil assigns(:account)
    assert_equal account_params[:name_to_show], @account.name_to_show
    assert_equal account_params[:category], @account.category
    assert_equal account_params[:provider_aptour_id], @account.provider_aptour_id
  end

  test 'should destroy an account' do
    accounts_count = Account.count

    delete :destroy, id: @account.account_api_id

    assert_response :found
    assert_redirected_to settings_path
    assert accounts_count - 1, Account.count
  end

  private

  def account_params
    {
      name_to_show: 'SANTANDER PESOS',
      category:     2,
      provider_aptour_id: 999
    }
  end

end
