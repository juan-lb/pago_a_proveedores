class ServicesController < ApplicationController

  before_action :set_service, only: [:update, :update_service]

  def edit
    @service = Service.find(params[:id])

    respond_to do |format|
      format.js { render 'edit' }
    end
  end

  def update
    respond_to do |format|
      if @service.update_attributes(service_params)
        flash[:success] = "Servicio actualizado."
        format.json {respond_with_bip(@service)}
      else
        flash[:error] = "Falló la actualización del servicio."
        format.json {respond_with_bip(@service)}
      end
    end
  end

  def update_service
    updater = ServiceUpdater.new(
      service: @service,
      params: service_params
    )

    messages = updater.call

    if messages != ServiceUpdater::NO_ERROR
      flash[:error] = messages
    else
      flash[:success] = 'Servicio actualizado correctamente.'
    end

    render 'reload_payment_group'
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:id, :euros, :amount, :leg_ope)
  end

end
