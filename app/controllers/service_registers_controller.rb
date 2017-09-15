class ServiceRegistersController < ApplicationController

  skip_before_action :verify_authenticity_token

  def index
    @presenter = ServiceRegistersPresenter.new(
      params: params,
      current_user: current_user,
      preselected: preselected(params)
    )

    check_results

    respond_to do |format|
      format.html {}
      format.js   {render :simple_index}
    end
  end

  def credits
    @presenter = ServiceRegistersPresenter.new(
      params: params,
      current_user: current_user,
      preselected: preselected(params)
    )

    render partial: 'panel_service_registers',
      locals: {
      favor: true,
      service_registers: @presenter.credits,
      preselected_service_registers: @presenter.preselected,
      type: "credit"
    },
    layout: nil
  end

  def add_services
    @presenter = ServiceRegistersPresenter.new(
      params:       params,
      current_user: current_user
    )

    aggregator = ServiceRegisterAggregator.new(
      registers_ids: registers_ids,
      current_user:  current_user,
      destiny:       params[:refund] || 'payment'
    )

    @registers_ids = registers_ids

    flash[:success] = "Servicios agregados" if aggregator.call
  end

  def remove_services
    ServiceRegisterRemover.new(
      services_ids: registers_ids,
      current_user: current_user
    ).call

    @presenter = ServiceRegistersPresenter.new(
      params: params,
      current_user: current_user
    )

    flash[:success] = "Servicios eliminados."

    respond_to do |format|
      format.js { render 'reload_all' }
    end
  end

  def payable
    @payable_manager = PayableManager.new(payable_params)
  end

  def possible_payments
    @manager = PossiblePaymentsManager.new(possible_payments_params)
  end

  def preselect_services
    @register_ids       = params[:register_ids]
    @operator_aptour_id = params[:operator_id]
    @open_on_new_tab    = true

    render '/service_registers/preselect_services'
  end

  def coming_entries
    @coming_entries_manager = ComingEntriesManager.new(coming_entries_params)
  end

  def by_file_number_form
  end

  def by_file_number
    services = ServiceRegister.where(id_res: params[:file_number])
    @error = Import.last.wrong_reserves.include? params[:file_number].to_i
    @operators = services.map do |each|
      {id: each.operator_aptour_id, name: each.nom_ope}
    end.uniq
  end

  def export_excel
    @service_registers = ServiceRegister.find(registers_ids)

    respond_to do |format|
      format.xlsx {
        render xlsx: "export_to_xlsx",
          locals: {
            xlsx_use_shared_strings: true
        }
      }
    end
  end

  private

  def payable_params
    params.require(:payable_manager).permit(
      :operator_category,
      :fec_type,
      :from,
      :to,
      :only_without_cc,
      :days
    ).to_h.deep_symbolize_keys if params[:payable_manager]
  end

  def possible_payments_params
    parameters = params.require(:possible_payments_manager).permit(
      :operator_id,
      :fec_type,
      :from,
      :to,
      :only_without_cc,
      :future_fec_out,
      :currency,
      statuses: []
    )
    parameters.merge!(operator_category) if params[:possible_payments_manager]
    parameters
  end

  def coming_entries_params
    params.require(:coming_entries_manager).permit(
      :days,
      :only_without_cc,
      :min_ars,
      :min_usd
    ).to_h.deep_symbolize_keys.merge(operator_category) if params[:coming_entries_manager]
  end

  def preselected(params)
    if params[:register_filter].present? && params[:register_filter][:register_ids]
      params[:register_filter][:register_ids].map(&:to_i)
    end
  end

  def registers_ids
    if params[:register_filter].present?
      params[:register_filter][:register_ids]
    else
      []
    end
  end

  def operator_category
    { operator_category: current_user.operator_category }
  end

  def check_results
    return unless params[:register_filter]

    result_message = ServiceRegistersIndexAgent.new(
      presenter: @presenter,
      filter_params: params[:register_filter]
    ).call

    flash[:error] = result_message unless result_message == ServiceRegistersIndexAgent::NO_ERROR
  end

end
