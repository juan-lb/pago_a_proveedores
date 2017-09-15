class InternationalPaymentGroupsController < PaymentGroupsController

  before_action :set_payment_group, only: [:show, :sent, :processed, :finished, :destroy, :draft, :export_to_excel, :bank_charges_form, :load_bank_charges, :apply_adjustment_form, :apply_adjustment]

  before_action :set_account_and_total, only: [:show]

  def show
    case @payment_group.status
    when 'Borrador'   then render_draft
    when 'En proceso' then render 'processed'
    when 'Cargado'    then render 'payment_groups/finished'
    else                   render 'payment_groups/show'
    end
  end

  def closed_without_bank_charges
    @payment_groups = PaymentGroup.without_bank_charges
  end

  def processed
    PaymentGroupStatusManager.new(
      payment_group: @payment_group,
      type:          :international,
      params:        params
    ).process

    flash[:success] = "Pago en proceso."
  end

  def sent
    if negative_balance?
      flash[:danger] = 'El monto a pagar no puede ser menor que el monto adeudado'
      redirect_to [@payment_group]
    else
      @payment = PaymentGroupStatusManager.new(
        payment_group: @payment_group,
        type:          :international,
        params:        params[:international_payment_group]
      ).send

      flash[:success] = 'Pago enviado.'
      render 'payment_groups/sent'
    end
  end

  def finished
    @payment_group.create_payment(payment_params)

    response = Transaction.new(@payment_group).call(
      fake_mode?,
      fake_mode_params
    )

    if response.ok?
      flash[:success] = 'La transacción se ha realizado exitosamente.'
    else
      flash[:danger] = "La transacción no se pudo completar. #{response.get_errors} "
    end

    redirect_to [@payment_group]
  end

  def bank_charges_form
  end

  def load_bank_charges
    @payment_group.payment.update(payment_params)

    response = BankChargesLoader.
      new(@payment_group).
      call(params[:payment][:bank_account])

    if response.ok?
      flash[:success] = 'La transacción se ha realizado exitosamente.'
    else
      flash[:danger] = "La transacción no se pudo completar. #{response.get_errors}."
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

  def total_to_pay
    params[:international_payment_group][:total].to_d
  end

  def total_payed
    payment = @payment_group.payment

    total =
      if FromTo.new(@payment_group, @account).call == 'DollarToDollar'
        payment.total_payment
      else
        payment.total_payment / payment.cotization
      end
  end

  def negative_balance?
    (total_to_pay < 0) || (total_to_pay + 0.5 < @payment_group.total)
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

  def payment_params
    params.
      require(:payment).
      permit(:total_payment, :total_debt, :cotization, :principal_reserve_id, :payment_method, :payment_method_number, :commission, :iva, :iibb_perception, :iva_perception, :eur_cotization) if params[:payment]
  end

end
