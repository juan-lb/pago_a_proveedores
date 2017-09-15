class OperatorsTransferAveragePdf < ToPdf

  def initialize(view)
    super(view)

    @view    = view
    @manager = OperatorsTransferAverage.new

    call
  end

  def call
    generate_header
    move_down 10
    text "Cociente entre lo pagado a un operador en el plazo de #{@manager.days} días y la cantidad de pagos realizados a dicho operador en el mismo plazo.", style: :italic
    move_down 20
    generate_tables
  end

  private

  def generate_header
    today = Date.today

    logo      'app/assets/images/logo.png'
    h4        'Promedio de transferencia por operador', aling: :center
    move_down 40
    field     'Fecha', today
    field     'Período', "#{today - @manager.days.days} - #{today}"
    field     'Días',  @manager.days
  end

  def generate_tables
    if @manager.international_transfers.any?
      h5 'Pagos Internacionales', align: :left
      display_table data(@manager.international_transfers, 'U$D', :international), true
      move_down 30
    end

    if @manager.national_usd_transfers.any?
      h5 'Pagos Nacionales en dólares', align: :left
      display_table data(@manager.national_usd_transfers, 'U$D', :national_usd), true
    end

    if @manager.national_ars_transfers.any?
      h5 'Pagos Nacionales en pesos', align: :left
      display_table data(@manager.national_ars_transfers, 'AR$', :national_ars), true
      move_down 30
    end

    if @manager.international_small_transfers.any?
      start_new_page
      h5 'Anexo'
      h6 "Pagos internacionales con promedio menor a #{@view.number_to_currency(Setting.take.transfer_average_usd_limit, unit: 'U$D')}",
        align: :left
      display_table special_data(
        @manager.international_small_transfers,
        'U$D'
      )
    end
  end

  def data(operators, currency, transfers_type)
    table = [['Operador', 'Promedio por pago']] + operators.map do |operator|
      [
        operator[:name],
        @view.number_to_currency(operator[:average], unit: currency)
      ]
    end

    table << [
      'TOTAL',
      @view.number_to_currency(@manager.totals[transfers_type], unit: currency)
    ]
  end

  def special_data(operators, currency)
    table = [
      ['Operador', 'Promedio por pago', 'Pagos', 'Cuentas']
    ] + operators.map do |operator|
      [
        operator[:name],
        operator[:count],
        @view.number_to_currency(operator[:average], unit: currency),
        operator[:accounts].join(', ')
      ]
    end
  end

end
