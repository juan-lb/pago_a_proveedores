class Admin::MainController < ApplicationController

  before_action :authorize

  def index
    @current_profile = current_user
  end

  private

  def authorize
    redirect_to root_path, warning: t(:unauthorized) unless admin?
  end

end
