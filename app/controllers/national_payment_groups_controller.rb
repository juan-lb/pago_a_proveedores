class NationalPaymentGroupsController < PaymentGroupsController

  before_action :set_payment_group, only: [:show, :sent, :finished, :export_to_excel, :ig_retention, :destroy, :draft, :apply_adjustment_form, :apply_adjustment]

  before_action :set_account_and_total, only: [:show]

  def show
    case @payment_group.status
    when 'Borrador'   then render_draft
    when 'Cargado'    then render 'payment_groups/finished'
    else                   render 'payment_groups/show'
    end
  end

  def sent
    @payment = PaymentGroupStatusManager.new(
      payment_group: @payment_group,
      type:          :national,
      params:        params[:national_payment_group]
    ).send

    flash[:success] = 'Pago enviado.'
    render 'payment_groups/sent'
  end

  def finished
    @payment_group.create_payment(payment_params)

    response = Transaction.new(@payment_group).call(
      fake_mode?,
      fake_mode_params
    )

    if response.ok?
      adapt_payment_total_to_currency
      flash[:success] = 'La transacción se ha realizado exitosamente.'
    else
      flash[:danger] = "La transacción no se pudo completar. #{response.get_errors} "
    end

    redirect_to [@payment_group]
  end

  def ig_retention
    respond_to do |format|
      format.html
      format.pdf do
        pdf = IgRetentionPdf.new(@payment_group, view_context)
        send_data pdf.render, filename: "RetIG_#{@payment_group.created_at.strftime("%d/%m/%Y")}.pdf",
            disposition: "inline", type: "application/pdf"
      end
    end
  end

  private

  def set_payment_group
    @payment_group = PaymentGroup.find(params[:id])
  end

  def set_account_and_total
    return unless @payment_group.closed?

    @account = Account.
      find_by_api_id(@payment_group.payment.payment_method)
    @total = total_payed
  end

  def payment_group_params
    params.
      require(:payment_group).
      permit!
  end

  def fake_mode?
    params[:payment][:bank_account].present? || params[:register_ids].present?
  end

  def fake_mode_params
    {
      account:           params[:payment][:bank_account],
      register_ids:      params[:register_ids],
      principal_reserve: params[:principal_reserve_id]
    }
  end

  def total_payed
    from_to = FromTo.new(@payment_group, @account).call
    payment = @payment_group.payment

    total =
      if from_to == 'DollarToDollar' || from_to == 'PesoToDollar'
        payment.total_payment
      else
        payment.total_payment / payment.cotization
      end
  end

  def payment_params
    params.
      require(:payment).
      permit(:total_payment, :total_debt, :cotization, :principal_reserve_id, :payment_method, :payment_method_number, :ig_retention) if params[:payment]
  end

  def adapt_payment_total_to_currency
    return if @payment_group.currency != 'D'

    p = @payment_group.payment
    p.update(total_payment: p.total_payment / p.cotization)
  end

end
