module FakeAuthentication

  def authenticate
    session[:cas_user] = profiles(:alfonsin).email
    @controller.class.skip_before_filter :cas_client_filter
    @controller.class.skip_before_filter :cas_filter
    @controller.class.skip_before_filter :current_user
  end

  def login(user)
    CASClient::Frameworks::Rails::Filter.fake(profiles(user).email)
  end

end
