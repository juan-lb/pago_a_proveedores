class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_filter :cas_filter, :current_user
  before_action :check_role,
    except: [:cas_filter, :logout, :current_user, :no_role, :forbidden]
  before_action :check_permissions,
    except: [:cas_filter, :logout, :current_user, :no_role, :forbidden, :home]
  before_action :set_current_profile,
    except: [:cas_filter, :logout, :current_user]
  before_action :check_import
  after_filter :flash_to_headers

  include ImportationChecker

  def cas_client_filter
    CASClient::Frameworks::Rails::Filter
  end

  def cas_filter
    CASClient::Frameworks::Rails::Filter.filter(self)
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  def current_user
    return unless session[:cas_user]

    @current_user ||= Profile.find_by(email: session[:cas_user])
  end

  helper_method :current_user

  def home
    @possible_payments_manager = PossiblePaymentsManager.new(
      operator_category: current_user.operator_category
    )
    @payable_manager = PayableManager.new
    @coming_entries_manager = ComingEntriesManager.new(
      days: 2,
      operator_category: current_user.operator_category
    )
  end

  def no_role
    @user = current_user
  end

  def forbidden
    @user = current_user
  end

  private

  def check_import
    import = Import.order('id DESC').first

    @import_failure =
      if Rails.env == 'development'
        false
      else
        import.nil? || ((import.created_at - Time.now).abs / 1.hour).round >= 12
      end

  end

  def set_current_profile
    @current_profile = current_user
  end

  def check_role
    redirect_to no_role_path unless has_role?
  end

  def check_permissions
    unless current_user.has_permissions?(params[:controller])
      redirect_to forbidden_path
    end
  end

  def user?
    is? 'user'
  end

  def admin?
    is? 'admin'
  end

  def is?(role)
    current_user.is?(role)
  end

  def has_role?()
    current_user.has_role?
  end

  def flash_to_headers
    return unless request.xhr?

    msg = flash_message.
      gsub("á","&aacute;").
      gsub("é","&eacute;").
      gsub("í","&iacute;").
      gsub("ó","&oacute;").
      gsub("ú","&uacute;")

    response.headers['X-Message']      = msg
    response.headers["X-Message-Type"] = flash_type.to_s

    flash.discard
  end

  def flash_message
    [:error, :warning, :notice, :success].each do |type|
      return flash[type] unless flash[type].blank?
    end

    ''
  end

  def flash_type
    [:error, :warning, :notice, :keep, :success].each do |type|
      return type unless flash[type].blank?
    end

    :empty
  end

end
