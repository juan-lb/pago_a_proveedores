class ReservesController < ApplicationController

  before_action :set_reserve, only: [:show]

  def show
    @presenter = ReservePresenter.new(
      reserve: @reserve,
      params: params
    )

    respond_to do |format|
      format.js
    end
  end

  private

  def set_reserve
    @reserve = Reserve.find(params[:id])
  end

end
