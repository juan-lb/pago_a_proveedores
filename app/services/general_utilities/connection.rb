class Connection

  def initialize(url)
    @connection = Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.response :json, content_type: 'application/json'
      faraday.adapter  Faraday.default_adapter

      faraday.options.timeout      = 60001
      faraday.options.open_timeout = 60001
    end
  end

  def get_reserve(reserve_id)
    @connection.get "/reserves/#{reserve_id}"
  end

  def get_reserve_services(reserve_id)
    @connection.post '/reserves/services', {
      reserve_id: reserve_id
    }
  end

  def get_content(hasta, id_ope, notid_usu, consaldos, id_cat2, id_usu)
    @connection.get '/payment_anticipations', {
      hasta:     hasta,
      id_ope:    id_ope,
      notid_usu: notid_usu,
      consaldos: consaldos,
      id_cat2:   id_cat2,
      id_usu:    id_usu
    }
  end

  def get_paid_by_agencies(reserves_ids)
    @connection.post 'reserves/paid_by_agency', {
      reserves_ids: reserves_ids
    }
  end

  def get_paid_to_operators(reserve_id)
    @connection.get "reserves/#{reserve_id}/operators_payments"
  end

  def get_multiple_paid_to_operators(reserve_ids)
    @connection.post "reserves/multiple_operators_payments", {
      reserve_ids: reserve_ids
    }
  end

  def get_service_status(reserve_id, service_id)
    response = @connection.get '/service_status', {
      reserve_id: reserve_id,
      numero:     service_id
    }
  end

  def get_service_dates(registers)
    response = @connection.post '/service_dates', {
      service_registers: registers
    }
  end

  def get_debt(reserve_id)
    response = @connection.get '/debt', {
      reserve_id: reserve_id
    }
  end

  def pay_reserve(amount, operator_id, reserve_id, currency, comment)
    response = @connection.get '/pay_reserve', {
      amount:      amount,
      operator_id: operator_id,
      reserve_id:  reserve_id,
      currency:    currency,
      comment:     comment
    }
  end

  def pay_refund(amount, operator_id, reserve_id, currency, comment)
    response = @connection.get '/pay_refund', {
      amount:      amount,
      operator_id: operator_id,
      reserve_id:  reserve_id,
      currency:    currency,
      comment:     comment
    }
  end

  def transfer_reserve(amount, operator_id, reserve_id_from, reserve_id_to, currency)
    response = @connection.get '/transfer',{
      amount:          amount,
      operator_id:     operator_id,
      reserve_id_from: reserve_id_from,
      reserve_id_to:   reserve_id_to,
      currency:        currency
    }
  end

  def get_accounts
    @connection.get '/accounts'
  end

  def get_all_accounts
    @connection.get '/all_accounts'
  end

  def get_subaccounts(id)
    @connection.get '/subaccounts', {id: id}
  end

  def get_account(account_id)
    @connection.get '/account',{
      id: account_id
    }
  end

  def erase_table
    @connection.get '/erase'
  end

  def for_pag_ins(id_cue, tipo, monto, cotizacion_uno, cotizacion_dos, ref_pago, fecha, cuota, tipo_operacion)
    @connection.get '/pag_ins', {
      id_cue: id_cue,
      tipo: tipo,
      monto: monto,
      cotizacion_uno: cotizacion_uno,
      cotizacion_dos: cotizacion_dos,
      ref_pago: ref_pago,
      fecha: fecha,
      cuota: cuota,
      tipo_operacion: tipo_operacion,
    }
  end

  def load_taxes(aliquot, base, tax_type = 3, accumulated, paid)
    @connection.post '/load_taxes', {
      aliquot:     aliquot,
      base:        base,
      tax_type:    tax_type,
      accumulated: accumulated,
      paid:        paid
    }
  end

  def asiento_ins(operator_name, total, date, user_aptour_initials)
    @connection.get '/asiento_ins',{
      nom_ope:     operator_name,
      monto_total: total,
      fecha:       date,
      initials:    user_aptour_initials
    }
  end

  def custom_asiento_ins(operator_name, reserve_id, total, currency, type = 'E')
    symbol  = currency == 'P' ? 'AR$' : 'U$D'
    details = "#{operator_name} - Reserva: #{reserve_id} - Compensación - #{symbol} #{total} - #{Date.today}"

    @connection.get '/asiento_ins', {
      detalle:         details,
      currency:        currency,
      cost_center_one: 2, # AEROTOURS
      cost_center_two: 2, # CUENTA N
      type:            type
    }
  end

  #Marca un servicio de una reserva como 'enviado' poniendo un 1, o lo cancela poniendo un 0
  def change_status(reserve_id, service_number, binary_boolean)
    @connection.get '/change_status',{
      reserve_id:     reserve_id,
      service_number: service_number,
      binary_boolean: binary_boolean
    }
  end

  #Retorna el servicio cuyo localizador (leg_ope) es igual, pero reserva es distinta
  def get_service_with_leg_ope(leg_ope, reserve_id)
    @connection.get '/service',{
      leg_ope:    leg_ope,
      reserve_id: reserve_id
    }
  end

  #Retorna la cotización del dólar del día
  def get_usd_cotization
    response = @connection.get 'current/peso/dolar/bsp'
  end

  #Retorna la cotización del uero del día
  def get_eur_cotization
    response = @connection.get 'current/peso/euro/base'
  end

  def generate_bank_charges_invoice(options)
    response = @connection.get 'invoices/insert', options
  end

  def get_users
    @connection.get 'statistics/users'
  end

  def get_last_transactions(options)
    @connection.get 'transactions/by_date', options
  end

  def get_paxs_by_file_number(file_number)
    @connection.get 'paxs/by_file_number', {file_number: file_number}
  end

  def get_paxs_by_name(name)
    @connection.get 'paxs/by_name', {name: name}
  end

  def get_reserves_by_locator(code, operator_id)
    @connection.get do |req|
      req.url 'find_by_confirmation_code'
      req.params = {
        code:        code,
        operator_id: operator_id
      }
      req.headers['Authorization'] = ENV['MO_SERVICES_TOKEN']
    end
  end

  def get_locators(params)
    services = params.map do |each|
      {
        aptour_reserve_id:     each[:reserve_id],
        aptour_service_number: each[:service_number]
      }
    end

    @connection.post do |req|
      req.url 'confirmation_codes'
      req.params = {querys: services, per_page: 999}
      req.headers['Authorization'] = ENV['MO_SERVICES_TOKEN']
    end
  end

end
