class OperatorsPositiveBalancesPdf < ToPdf

  def initialize(params, view)
    super(view)

    @view      = view
    @presenter = OperatorsPositiveBalancesPresenter.new(
      params: ActionController::Parameters.new(params)
    )
    @operators = @presenter.operators_with_credits
    cotization = Cotizator.new.usd_cotization

    @national = @operators.
      select { |each| each[:category] == :national }.
      sort   { |a, b| b[:ars] + b[:usd]*cotization <=> a[:ars] + a[:usd]*cotization }

    @international = @operators.
      select { |each| each[:category] == :international }.
      sort   { |a, b| b[:ars] + b[:usd]*cotization <=> a[:ars] + a[:usd]*cotization }

    call
  end

  def call
    generate_header
    move_down 30
    generate_tables
  end

  private

  def generate_header
    logo 'app/assets/images/logo.png'
    @category = @presenter.filter.category
    category =
      if @category.present? && @category == 'national'
        'Nacionales'
      elsif @category.present? && @category == 'international'
        'Internacionales'
      else
        'Nacionales e internacionales'
      end

    h4        'Saldos a favor por operador', aling: :center
    move_down 40
    field     'Fecha', Date.today
    field     'Categoría de operadores', category
  end

  def generate_tables
    if @category.blank? || @category == 'national'
      h5 'Operadores nacionales', align: :left
      display_table data(@national)

      move_down 30
    end

    if @category.blank? || @category == 'international'
      h5 'Operadores internacionales', align: :left
      display_table data(@international)
    end
  end

  def data(operators)
    [['Nombre', 'AR$', 'U$D']] + operators.map do |operator|
      [
        operator[:name],
        @view.number_with_precision(operator[:ars]),
        @view.number_with_precision(operator[:usd])
      ]
    end


  end

end
