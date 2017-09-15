class ImportsController < ApplicationController

  skip_before_action :verify_authenticity_token, if: :js_request?
  skip_before_action :cas_filter, only: [:remote_load]
  skip_before_action :check_role, only: [:remote_load]
  skip_before_action :check_if_importation_is_running, only: :importation_running

  def index
    @imports = Import.
      all.
      order('created_at DESC').
      paginate(
        page:     params[:page],
        per_page: Const::PER_PAGE
      )
  end

  def load_all
    import = Import.load(gateway: :manual)

    if import.wrong_reserves.empty?
      flash[:success] = 'Importación exitosa.'
    else
      flash[:warning] = 'Hay reservas que no se pudieron cargar. Revise la sección de Importaciones.'
    end

    redirect_to root_path

  rescue Exception => e
    Setting.stop_importation
    flash[:error] = "Falló la importación. Error message: #{e}"
    redirect_to root_path
  end

  def load
    import = Import.load(
      gateway:     :manual,
      operator_id: params[:operator_id].to_i
    )

    if import.wrong_reserves.empty?
      flash[:success] = 'Importación exitosa.'
    else
      flash[:warning] = 'Hay reservas que no se pudieron cargar. Revise la sección de Importaciones.'
    end

    redirect_to root_path

  rescue Exception => e
    Setting.stop_importation
    flash[:error] = "Falló la importación. Error message: #{e}"
    redirect_to root_path
  end

  def importation_running
    if Setting.is_importation_running?
      render :importation_running, status: 503, layout: 'simple'
    else
      redirect_to root_path
    end
  end

  protected

  def js_request?
    request.format.js?
  end

end
