class FundFlowController < ApplicationController

  before_action :set_presenter

  def index; end

  def operator; end

  private

  def set_presenter
    @presenter = FundFlowPresenter.new(params)
  end

end
