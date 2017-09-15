class PaymentProcessor

  def initialize(payment_group, profile: nil)
    @payment_group = payment_group
    @payment       = payment_group.payment
    @connection    = Connection.new(ENV["APTOUR_URL"])
    @response      = Response.new
    @account       = Account.get_account(@payment.payment_method)
    @profile       = profile || Struct.new(:aptour_initials).new('AR')
  end

  def erase_table
    response = @connection.erase_table

    if response.status != 200
      @response.add_error('erase_table', response.status, response.body)
    end

  rescue Faraday::ConnectionFailed
    @response.add_error('erase_table', 666, 'Fallo de conexión')
  end

  def for_pag_ins(id_cue, tipo, monto, cotizacion_uno, cotizacion_dos, ref_pago, fecha, cuota, tipo_operacion)
    response = @connection.for_pag_ins(id_cue, tipo, monto, cotizacion_uno, cotizacion_dos, ref_pago, fecha, cuota, tipo_operacion)

    if response.status != 200
      @response.add_error('for_pag_ins', response.status, response.body)
    end

  rescue Faraday::ConnectionFailed
    @response.add_error('for_pag_ins', 666, 'Fallo de conexión')
  end

  def load_retention
    return true unless @payment_group.operator.has_ig_retention

    setting   = Setting.take
    retention = IgRetention.find_by(
      operator_aptour_id: @payment_group.operator_aptour_id
    )

    return true if retention.nil?

    base = @payment.ig_retention.to_f / (setting.ig_aliquot / 100)
    base *= @payment.cotization.to_f if @payment_group.currency == 'D'

    return true if base.zero?

    @connection.load_taxes(
      setting.ig_aliquot,
      base,
      3, # Retención de ganancias
      retention.accumulated.to_f + @payment.total_payment + @payment.ig_retention,
      @payment.total_payment
    )
  end

  def pay_reserve(total)
    @payment.update(payment_date: Date.today)

    response = @connection.pay_reserve(
      total,
      @payment_group.operator_aptour_id,
      @payment.principal_reserve_id,
      @payment_group.currency,
      ''
    )

    if response.status != 200
      @response.add_error('pay_reserve', response.status, response.body)
    end

  rescue Faraday::ConnectionFailed
    @response.add_error('pay_reserve', 666, 'Fallo de conexión')
  end

  def pay_refund(total)
    @payment.update(payment_date: Date.today)

    response = @connection.pay_refund(
      total,
      @payment_group.operator_aptour_id,
      @payment.principal_reserve_id,
      @payment_group.currency,
      ''
    )

    if response.status != 200
      @response.add_error('pay_reserve', response.status, response.body)
    end

    @response
  rescue Faraday::ConnectionFailed
    @response.add_error('pay_reserve', 666, 'Fallo de conexión')
  end

  def asiento_ins(operator_name, total)
    response = @connection.asiento_ins(
      operator_name,
      total,
      Date.today,
      @profile.aptour_initials
    )

    if response.body.first["RETORNO"] == '10'
      @payment.update(id_mov_in_aptour: response.body.first["id_mov"])
    else
      @response.add_error('asiento_ins', response.status, response.body)
    end

  rescue Faraday::ConnectionFailed
    @response.add_error('asiento_ins', 666, 'Fallo de conexión')
  end

  def custom_asiento_ins(total, currency, type)
    response = @connection.custom_asiento_ins(
      @payment_group.operator.name,
      @payment.principal_reserve_id,
      total,
      currency,
      type
    )

    if response.body.first["RETORNO"] == '10'
      @payment.update(id_mov_in_aptour: response.body.first["id_mov"])
    else
      @response.add_error('asiento_ins', response.status, response.body)
    end

  rescue Faraday::ConnectionFailed
    @response.add_error('asiento_ins', 666, 'Fallo de conexión')
  end


  def load_bank_charges(total, account_id=@payment.payment_method)
    return nil unless total > 0

    account = Account.find_by(account_api_id: account_id)
    account_type = (@payment_group.category == 2) ? 'B' : 'E'

    if account.simple_currency != 'P'
      cotization = @payment.cotization
    else
      cotization = 1.0000
    end

    for_pag_ins(
      account_id,
      account_type,
      total,
      cotization,
      1.0000,
      '',
      '',
      0,
      'C'
    )

    @connection.generate_bank_charges_invoice(
      build_bank_charges_invoice(total, account)
    ) if @payment_group.category == 2
  end

  private

  def build_bank_charges_invoice(total, account)
    {
      id_ope: account.provider_aptour_id,
      sucur: '0009',
      numero: @payment.unique_value_for_invoices,
      detalle: "GASTO TRANSFERENCIA [#{@payment_group.operator_name}]",
      ref: '',
      id_comp: 'LQ',
      fecha: Time.now,
      importe: total,
      ng: @payment.commission,
      nc: 0,
      exento: 0,
      iva: @payment.iva,
      por_iva: 21,
      por_por_iva: 100,
      mes: Date.today.month.to_s,
      ano: Date.today.year.to_s.last(2),
      id_usu: "AR",
      sucursal: 1,
      fnl: 'CO',
      cocc: 'CO',
      op: 'P',
      ret: 0,
      per_iva: 0,
      per_ing_bru: 0,
      ret_gan: 0,
      ret_iva: 0,
      ret_ing_bru: 0,
      iva_int: 0,
      per_int: 0,
      ser_cuo: 0,
      des_com: 0,
      gravado1: 0,
      iva1: 0,
      por_iva1: 10.5,
      moneda: account.simple_currency,
      cotizacion: @payment.cotization,
      cai: '',
      fecha_cai: nil,
      con_cc: 'CO',
      vto_fac: Time.now,
      id_razon: 0,
      id_provper: 0,
      id_centro_costos: 2,
      id_centro_costos2: 1
    }
  end

end
