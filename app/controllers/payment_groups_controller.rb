class PaymentGroupsController < ApplicationController

  before_action :set_payment_group, only: [:destroy, :draft, :export_to_excel, :show_credit, :process_credit, :transfer, :report, :export, :change_currency, :change_to_refund, :remove_incompatible_services, :payment_report_form, :send_payment_report, :apply_adjustment_form, :apply_adjustment, :update_locators]
  before_action :get_usd_cotization, only: [:show, :sent, :processed]

  def index
    @presenter = PaymentGroupsPresenter.new(
      params: params.merge({page: params[:page]}),
      current_user: current_user
    )
  end

  def destroy
    manager = PaymentGroupDestroyerManager.new(@payment_group).call

    @operator_aptour_id = @payment_group.operator_aptour_id
    @register_ids       = manager.register_ids

    if @payment_group.destroy
      flash[:success] = 'El pago ha sido eliminado.'
    else
      flash[:warning] = 'El pago no ha podido eliminarse.'
    end

    render '/service_registers/preselect_services'
  end

  def draft
    result = PaymentGroupManager.new(
      payment_group: @payment_group,
      current_user:  current_user
    ).change_to_draft

    if result == PaymentGroupManager::NO_ERROR
      flash[:success] = 'Pago pasado a estado BORRADOR.'
    else
      flash[:error] = PaymentGroupManager::DRAFT_ERROR
    end

    redirect_to [@payment_group]
  end

  def export_to_excel
    @in_euros = params[:in_euros]

    respond_to do |format|
      format.xlsx {
        render xlsx: "export_to_xlsx",
          locals: {
            xlsx_use_shared_strings: true
        }
      }
    end
  end

  def report
    @report = @payment_group.payment_group_report || create_report
  end

  def show_credit
    set_payment_group

    if @payment_group.draft?
      redirect_to service_registers_path(
        register_filter: {
          operator_id: @payment_group.operator_aptour_id
        }
      )
    elsif @payment_group.in_process?
      render 'process_credit'
    else
      @account = Account.find_by_api_id(@payment_group.payment.payment_method)
      render 'show'
    end

  end

  def process_credit
    result = PaymentGroupManager.new(
      payment_group: set_payment_group,
      current_user: current_user
    ).process_credit

    if result == PaymentGroupManager::NO_ERROR
      render 'process_credit'
    else
      flash[:danger] = result
      redirect_to service_registers_path(
        register_filter: {
          operator_id: @payment_group.operator_aptour_id
        }
      )
    end

  end

  def transfer
    set_payment_group
    @payment_group.create_payment(payment_params)

    response = Transaction.new(@payment_group).call

    if response.ok?
      flash[:success] = 'La transacción se ha realizado exitosamente'
    else
      flash[:danger] = "Error en la transacción. #{response.get_errors} "
    end

    redirect_to [:show_credit, @payment_group]
  end

  def change_currency
    @presenter = ServiceRegistersPresenter.new(
      params: params[:old_params],
      current_user: current_user
    )

    PaymentGroupManager.new(
      payment_group: @payment_group,
      current_user: current_user
    ).change_currency

    respond_to do |format|
      flash[:success] = "Operación realizada."
      format.js {render 'service_registers/reload_all'}
    end

  end

  def change_to_refund
    respond_to do |format|
      if @payment_group.credit_with_no_debits?
        @payment_group.update(type: 'RefundPaymentGroup')

        @presenter = ServiceRegistersPresenter.new(
          params: params[:old_params],
          current_user: current_user
        )

        flash[:success] = "Operación realizada."
        format.js {render 'service_registers/reload_all'}
      else
        flash[:error] = "Elimine todos los débitos para iniciar devolución."
        format.js {head :ok}
      end
    end
  end

  def remove_incompatible_services
    @presenter = ServiceRegistersPresenter.new(
      params: params[:old_params],
      current_user: current_user
    )

    PaymentGroupManager.new(
      payment_group: @payment_group,
      current_user: current_user
    ).remove_incompatible_services

    respond_to do |format|
      flash[:success] = "Operación realizada."
      format.js { render 'service_registers/reload_all' }
    end

  end

  def payment_report_form; end

  def send_payment_report
    PaymentReport.new(
      payment_report_params,
      @payment_group,
      view_context
    ).send(@payment_group.payment_group_report)

    flash[:success] = 'Se ha enviado el correo correctamente'
  end

  def apply_adjustment_form; end

  def apply_adjustment
    IncomeAdjustmentManager.new(
      @payment_group,
      params[:coefficient],
      params[:payment_comment]
    ).call

    flash[:success] = 'Pago ficticio generado.'
  end

  def update_locators
    if LocatorsUpdater.new(payment_group: @payment_group).call
      flash[:success] = 'Localizadores actualizados.'
    else
      flash[:warning] = 'No se han actualizado los localizadores.'
    end

    redirect_to report_payment_group_path(@payment_group)
  end

  private

  def get_usd_cotization
    @usd_cotization = Cotizator.new.usd_cotization
  end

  def set_payment_group
    @payment_group = PaymentGroup.find(params[:id])
  end

  def payment_group_params
    params.require(:payment_group).permit!
  end

  def filter_params
    params.require(:payment_group_filter).permit(:operator_id, :operator_category, :status, :reserve, :leg_ope, :from, :to, :passenger) if params[:payment_group_filter]
  end

  def payment_params
    params.require(:payment).permit(:total_payment, :total_debt, :cotization, :principal_reserve_id, :payment_method, :payment_method_number, :commission, :iva, :iibb_perception, :iva_perception) if params[:payment]
  end

  def payment_report_params
    params.require(:payment_report).permit(:to, :sender, :message, :swift)
  end

  def create_report
    PaymentGroupReport.create(
      payment_group: @payment_group,
      note:          current_user.report_message
    )
  end

  def render_draft
    redirect_to service_registers_path(
      register_filter: {operator_id: @payment_group.operator_aptour_id}
    )
  end

end
