class AgencyPayments

  attr_accessor :receipts, :total_usd, :total_ars, :from, :to, :accounts, :reserves

  def initialize(attrs)
    attrs ||= {}

    @from     = attrs[:from] || Date.yesterday
    @to       = attrs[:to]   || Date.yesterday
    @receipts = get_receitps

    return nil if receipts.nil?

    set_totals
    set_accounts_receipts
    set_reserves_receipts
  end

  private

  def get_receitps
    con = Connection.new(ENV['APTOUR_URL'])
    res = con.get_last_transactions({desde: @from, hasta: @to})

    return nil if res.status != 200

    process_results res.body.flatten
  end

  def process_results(data)
    data.
      select { |each| each['NOM_MOV'].strip == 'RECIBOS' }.
      flat_map do |each|
        {
          name:        each['NOMBRE'].strip,
          account:     each['NOM_CUE'].strip,
          time:        each['fecha'].to_datetime.strftime("%H:%M"),
          currency:    set_currency(each['CTA_CTE'].strip),
          amount:      each['importe'].to_f,
          cotization:  set_cotization(each['COTIZACION']),
          file_number: each['ID_RES']
        }
      end
  end

  def set_currency(currency)
    case currency
      when 'P' then 'ARS'
      when 'D' then 'USD'
      else '-'
    end
  end

  def set_cotization(value)
    return 1.0 if value.nil?

    value = value.to_f
    value == 0 ? 1.0 : value
  end

  def set_accounts_receipts
    @accounts = {}

    receipts.each do |receipt|
      next if receipt[:account].nil?

      key = receipt_key receipt[:account]

      @accounts[key] = {
        name: key,
        ars:  0,
        usd:  0
      } if @accounts[key].nil?

      if receipt[:currency] == 'ARS'
        @accounts[key][:ars] += receipt[:amount] * receipt[:cotization]
      else
        @accounts[key][:usd] += receipt[:amount] / receipt[:cotization]
      end

    end

    @accounts = @accounts.sort_by { |key,value| value[:name] }.to_h
  end

  def set_reserves_receipts
    @reserves = {}

    set_operators_name receipts

    receipts.each do |receipt|
      next if receipt[:file_number].nil?

      key = receipt[:file_number]

      @reserves[key] = {
        file_number: key,
        ars:         0,
        usd:         0,
        operators:   @operators[key]
      }

      if receipt[:currency] == 'ARS'
        @reserves[key][:ars] += receipt[:amount] * receipt[:cotization]
      else
        @reserves[key][:usd] += receipt[:amount] / receipt[:cotization]
      end

    end

    @reserves = @reserves.sort_by { |key,val| val[:file_number]}.to_h
  end

  def set_totals
    @total_usd = receipts.
      select    { |each| each[:currency] == 'USD' }.
      inject(0) { |sum,each| sum + receipt_total(each, 'D') }

    @total_ars = receipts.
      select    { |each| each[:currency] == 'ARS' }.
      inject(0) { |sum,each| sum + receipt_total(each, 'P') }
  end

  def receipt_key(name)
     return 'TRANSFERENCIAS' if name.downcase.include? 'transferencia'
     return 'CHEQUES'        if name.downcase.include? 'cheques'

     return 'TARJETAS AERO'  if AERO_CARDS.include? name.upcase
     return 'TARJETAS CIAS'  if CIAS_CARDS.include? name.upcase
     return 'BANCOS'         if BANKS.include?      name.upcase

     return 'EFECTIVO'       if name.downcase.include?('dolares') ||
                                name.downcase.include?('pesos')

     name
  end

  def receipt_total(receipt, currency)
    if currency == 'P'
      receipt[:amount] * receipt[:cotization]
    elsif currency == 'D'
      receipt[:amount] / receipt[:cotization]
    else
      0
    end
  end

  def set_operators_name(receipts)
    @operators = {}
    files      = receipts.map { |each| each[:file_number] }.compact

    ServiceRegister.where(id_res: files).each do |service|
      key           = service.id_res
      operator_name = service.nom_ope.strip

      @operators[key] = [] unless @operators[key]

      unless @operators[key].include? operator_name
        @operators[key] << operator_name
      end

    end
  end

  BANKS = [
    'CITI CTA CTE PESOS',
    'BCO RIO AERO SRL PESOS',
    'BANCO RIO AERO SRL DOLARES',
    'MACRO PESOS',
    'NACION CTA CTE',
    'PROVINCIA AERO SRL PESOS',
    'PATAGONIA PESOS',
    'COMAFI',
    'GALICIA BCO PESOS'
  ]

  AERO_CARDS = [
    'POSNET',
    'VISA POSNET',
    'MASTER / DINERS POSNET',
    'AMEX POSNET'
  ]

  CIAS_CARDS = [
    'TARJETAS 2',
    'IATA - TASF',
    'TUCUMAN TARJETAS 2',
    'SPORT TARJETAS 2',
    'BIBLOS TARJETAS 2'
  ]

end
