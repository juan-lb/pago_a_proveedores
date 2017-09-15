class AccountsController < ApplicationController

  before_action :set_account, only: [:destroy]

  def create
    if params[:accounts].present?
      AccountsGenerator.new(params[:accounts]).call
      flash[:success] = 'Las cuentas han sido agregadas exitosamente.'
    else
      flash[:error] = 'Seleccione al menos una cuenta.'
    end

    redirect_to settings_path
  end

  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(account_params)
        flash[:success] = "Operación realizada."
        format.json { respond_with_bip(@account) }
      else
        flash[:error] = "Error al actualizar."
        format.json { respond_with_bip(@account) }
      end
    end

  end

  def destroy
    if @account.destroy
      flash[:success] = "La cuenta ha sido eliminada exitosamente"
    else
      flash[:error] = "No se ha podido eliminar la cuenta"
    end

    redirect_to settings_path
  end

  private

  def account_params
    params.require(:account).permit(:category, :name_to_show, :provider_aptour_id)
  end

  def set_account
    @account = Account.find_by_api_id(params[:id])
  end

end
