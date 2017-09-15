class SettingsController < ApplicationController

  before_action :set_setting, only: [:update, :edit_emails, :update_emails]

  def index
    @api_accounts = Account.all_filter
    @accounts     = Account.all
    @setting      = Setting.take
  end

  def update
    respond_to do |format|
      if @setting.update_attributes(setting_params)
        flash[:success] = 'Operación realizada.'
        format.json {respond_with_bip(@setting)}
      else
        flash[:error] = 'Error al actualizar.'
        format.json {respond_with_bip(@setting)}
      end
    end
  end

  def edit_emails; end

  def update_emails
    target = params[:setting][:target].to_sym

    if target == :operators_average
      @setting.update operators_average_emails: formatted_emails
    elsif target == :positive_balances
      @setting.update positive_balances_emails: formatted_emails
    end

    flash[:success] = 'Operación realizada.'
  end

  private

  def setting_params
    params.require(:setting).permit(:ig_limit, :ig_aliquot, :ig_base, :max_usd_credit_dif, :max_ars_credit_dif, :operators_average_days, :min_ars_credit_report, :min_usd_credit_report, :transfer_average_usd_limit)
  end

  def set_setting
    @setting = Setting.take
  end

  def formatted_emails
    params[:setting][:emails].
      tr('[', '').
      tr(']', '').
      tr('\"', '').
      split(',')
  end

end
