class RefundPaymentGroupsController < PaymentGroupsController

  before_action :set_payment_group, only: [:show, :destroy, :processed, :finished, :destroy, :draft]

  before_action :set_account_and_total, only: [:show]

  def show
    case @payment_group.status
    when 'Borrador'   then render_draft
    when 'En proceso' then render 'processed'
    when 'Cargado'    then render 'payment_groups/finished'
    else                   render 'payment_groups/show'
    end
  end

  def processed
    @payment = PaymentGroupStatusManager.new(
      payment_group: @payment_group,
      type:          :refund,
      params:        params
    ).process

    flash[:success] = 'Devolución en proceso.'
  end

  def finished
    @payment_group.create_payment(
      payment_params.merge({total_debt: @payment_group.total})
    )

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

  def payment_params
    params.require(:payment).permit(:total_payment, :total_debt, :cotization, :principal_reserve_id, :payment_method, :payment_method_number, :commission, :iva, :iibb_perception, :iva_perception, :eur_cotization) if params[:payment]
  end

  def total_payed
    if FromTo.new(@payment_group, @account).call  == 'DollarToDollar'
      total = @payment_group.payment.total_payment
    else
      total = @payment_group.payment.total_payment / @payment_group.payment.cotization
    end
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

end
