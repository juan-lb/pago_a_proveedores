class OperatorInformationsController < ApplicationController

  before_action :set_operator_information, only: [:update]

  def new
   @operator_information = OperatorInformation.new(
     operator_aptour_id: params[:operator_aptour_id]
   )
  end

  def create
    @operator_information = OperatorInformation.new(
      operator_information_params
    )

    if @operator_information.save
      flash[:success] = 'Información actualizada.'
    else
      flash[:error] = 'Falló la actualización de la información.'
    end

  end

  def update
    respond_to do |format|
      if @operator_information.update_attributes(operator_information_params)
        flash[:success] = 'Información actualizada.'
        format.json {respond_with_bip(@operator_information)}
      else
        flash[:error] = 'Falló la actualización de la información.'
        format.json {respond_with_bip(@operator_information)}
      end
    end
  end

  private

  def set_operator_information
    @operator_information = OperatorInformation.find(params[:id])
  end

  def operator_information_params
    params.require(:operator_information).permit(:email, :operator_aptour_id)
  end

end
