class StatisticsReportPdf < ToPdf

  def initialize(params, view)
    super(view)
    @presenter = StatisticsPresenter.new(
      params: ActionController::Parameters.new(params)
    )
    @view       = view
    @category   = @presenter.filter.operator_category
    @cotization = @presenter.usd_cotization.round 2
    @total_ars  = @presenter.total_ars.round 2
    @total_usd  = @presenter.total_usd.round 2
    @total_eur  = @presenter.total_eur.round 2

    call
  end

  def call
    generate_header
    generate_general_statistics

    if @presenter.filter.comparison_mode
      start_new_page
      generate_comparison_statistics
    end

    start_new_page
    generate_operator_statistics
    start_new_page
    generate_bank_statistics
  end

  private

  def generate_header
    logo 'app/assets/images/logo.png'
    period = "#{@presenter.filter.from} - #{@presenter.filter.selected_to}"
    category = @presenter.filter.operator_category
    category =
      if category.present? && category == 'national'
        'Nacionales'
      elsif category.present? && category == 'international'
        'Internacionales'
      else
        'Nacionales e internacionales'
      end

    h4        'Estadísticas de pagos', aling: :center
    move_down 40
    field     'Fecha', Date.today
    field     'Periodo', period
    field     'Categoría de operadores', category
  end

  def generate_general_statistics
    move_down 20
    h5        'Estadísticas generales', align: :left
    move_down 5
    generate_general_statistics_data
    move_down 10
  end

  def generate_operator_statistics
    move_down 20
    h5        'Estadísticas por operador', align: :left
    move_down 5
    generate_operator_statistics_data
    move_down 10
  end

  def generate_bank_statistics
    move_down 20
    h5        'Estadísticas por banco', align: :left
    move_down 5
    generate_bank_statistics_data
    move_down 10
  end

  def generate_comparison_statistics
    move_down 20
    h5        'Comparación de estadísticas', align: :left
    move_down 5
    generate_comparison_statistics_data
    move_down 10
  end

  # -- Generación de datos

  def generate_general_statistics_data
    display_table amount_data
    move_down 5

    field(
      'Cotizatión promedio',
      @cotization
    ) if @category == 'national'

    move_down 5
    move_down 10
    display_table quantity_data
  end

  def amount_data
    if @category == 'national'
      data = [
        ['Moneda', 'Monto AR$', 'Monto U$D'],
        [
          'U$D',
          @view.number_to_currency(@total_usd * @cotization, unit: ''),
          @view.number_to_currency(@total_usd, unit: ''),
        ],
        [
          'AR$',
          @view.number_to_currency(@total_ars, unit: ''),
          @view.number_to_currency(@total_ars / @cotization, unit: ''),
        ],
        [
          'TOTAL',
          @view.number_to_currency(@total_usd * @cotization + @total_ars, unit: ''),
          @view.number_to_currency(@total_usd + @total_ars / @cotization, unit: '')
        ]
      ]
    else
      data = [
        ['Moneda', 'Monto'],
        ['U$D', @view.number_to_currency(@total_usd, unit: '')],
        ['EUR', @view.number_to_currency(@total_eur, unit: '')]
      ]
    end

    data << [
      'AR$',
      @view.number_to_currency(@total_ars, unit: '')
    ] if @category.blank?

    data
  end

  def quantity_data
    data = [
      ['Moneda', 'Cantidad'],
      ['U$D', @presenter.usd_payment_groups.count]
    ]

    data << [
      'AR$',
      @presenter.ars_payment_groups.count
    ] if @category != 'international'

    data << [
      'EUR',
      @presenter.eur_payment_groups.count
    ] if @category != 'national'

    data << ['TOTAL', @presenter.payment_groups.count]

    data
  end

  def generate_operator_statistics_data
    header = ['Operador', 'AR$']
    data   = build_operators_data(@presenter.amount_by_operators, :ars)
    ars    = [header].concat data

    header = ['Operador', 'U$D']
    data   = build_operators_data(@presenter.amount_by_operators, :usd)
    usd    = [header].concat data

    header = ['Operador', 'EUR']
    data   = build_operators_data(@presenter.amount_by_operators, :eur)
    eur    = [header].concat data

    data = @presenter.quantity_by_operators.values.map do |each|
      [ each[:name], each[:quantity] ]
    end

    quantity_data = [['Operador', 'Cantidad']].concat(data)

    h6 'Montos por operador', align: :left
    display_table(ars)
    display_table(usd)
    display_table(eur)
    move_down 10
    h6 'Cantidades por operador', align: :left
    display_table(quantity_data)
  end

  def generate_bank_statistics_data
    data        = build_data(@presenter.amount_by_bank)
    header      = build_header('Banco')
    amount_data = [header].concat(data)

    data = @presenter.quantity_by_bank.values.map do |each|
      [ each[:name], each[:quantity] ]
    end

    quantity_data = [['Operador', 'Cantidad']].concat(data)

    h6 'Montos por banco', align: :left
    display_table(amount_data)
    move_down 10
    h6 'Cantidades por banco', align: :left
    display_table(quantity_data)
  end

  def generate_comparison_statistics_data
    ars = format_total_by_month('AR$',@presenter.total_ars_by_month)
    usd = format_total_by_month('U$D',@presenter.total_usd_by_month)
    eur = format_total_by_month('EUR',@presenter.total_eur_by_month)

    ars_count = format_quantity_by_month('AR$', @presenter.total_ars_by_month)
    usd_count = format_quantity_by_month('U$D', @presenter.total_usd_by_month)
    eur_count = format_quantity_by_month('EUR', @presenter.total_eur_by_month)

    quantity_data = ars_count.merge(usd_count).merge(eur_count)
    complete_quanity_by_month(quantity_data)

    h6 'Monto de pagos realizados', align: :left
    chart usd,
      colors: ['4CAF50'],
      labels: [true],
      steps: 10

    chart eur,
      colors: ['F44336'],
      labels: [true],
      steps:  10 if @category != 'national'

    start_new_page if @category == ''

    chart ars,
      colors: ['2196F3'],
      labels: [true],
      steps:  10 if @category != 'international'

    start_new_page if @category != ''
    move_down 20
    h6 'Cantidad de pagos realizados', align: :left

    chart quantity_data,
      colors: ['2196F3','4CAF50','F44336'],
      steps:  10,
      type:   :stack

  end

  # -- Formateo de datos

  def format_total_by_month(currency, records)
    {currency => records.
      map { |each| {each[:label] => each[:total]} }.
      reduce({}) { |sum,each| sum.merge each }
    }
  end

  def format_quantity_by_month(currency, records)
    {currency => records.
      map { |each| {each[:label] => each[:quantity]} }.
      reduce({}) { |sum,each| sum.merge each }
    }
  end

  def complete_quanity_by_month(records)
    keys = records.values.flat_map { |each| each.keys }.uniq
    keys.each do |key|
      records['AR$'][key] = 0 if records['AR$'][key].nil?
      records['U$D'][key] = 0 if records['U$D'][key].nil?
      records['EUR'][key] = 0 if records['EUR'][key].nil?
    end
  end

  def build_header(title)
    header = [title, 'U$D', 'AR$', 'EUR']
    header.reject! {|x| x == 'AR$'} if @category == 'international'
    header.reject! {|x| x == 'EUR'} if @category == 'national'
    header
  end

  def build_data(records)
    records.values.map do |each|
      data = [
        each[:name],
        @view.number_to_currency(each[:usd].round, unit: '')
      ]

      if @category != 'international'
        data << @view.number_to_currency(each[:ars].round, unit: '')
      end

      if @category != 'national'
        data << @view.number_to_currency(each[:eur].round, unit: '')
      end

      data
    end
  end

  def build_operators_data(records, currency)
    matrix = records.values.map do |each|
      [
        each[:name],
        each[currency]
      ]
    end

    matrix.
      reject  { |each| each[1] == 0 }.
      sort_by { |each| each[1] }.
      reverse.
      map do |each|
        [
          each[0],
          @view.number_to_currency(each[1].round, unit: '')
        ]
      end
  end

end
