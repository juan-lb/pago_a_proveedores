class AgencyPaymentsController < ApplicationController

  def index
    @manager = AgencyPayments.new(filter_params)
  end

  private

  def filter_params
    params.require(:agency_payment).permit(:from, :to) if params[:agency_payment].present?
  end

end
