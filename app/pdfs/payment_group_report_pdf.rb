class PaymentGroupReportPdf < Prawn::Document

  def initialize(report, difference, view)
    super()

    @view          = view
    @report        = report
    @payment_group = report.payment_group
    @account       = @payment_group.payment.account
    @difference    = difference
    @operator      = @payment_group.operator
    @currency      = (@report.printable_column == 1 ? @payment_group.currency_symbol : '€')

    call
  end

  def call
    header
    presentation
    details
    services
    note
    swift
  end

  private

  def header
    move_down 10
    text "#{Date.today.strftime("%d/%m/%Y")}",
      indent_paragraphs: 430
  end

  def presentation
    move_down 10
    text "Sres. <strong>#{@operator.name.upcase}</strong>",
      inline_format: true
    move_down 10

    text_data = 'Por la presente se informa que ' +
      if @payment_group.payment.in_aptour
        ' hemos efectuado un pago a su nombre. '
      else
        ' próximamente estaremos realizando un pago a su nombre. '
      end

    text_data += 'A continuación se incluyen los detalles.'

    text text_data,
      indent_paragraphs: 15,
      inline_format:     true
  end

  def details
    move_down 10
    text "<strong>IMPORTE: </strong> #{amount}",
      inline_format:     true,
      indent_paragraphs: 30
    move_down 5

    if @account.present?
      text "<strong>CUENTA ORIGEN: </strong> #{@account.name_to_show}",
        inline_format:     true,
        indent_paragraphs: 30
    end

  end

  def amount
    total =
      if @report.printable_column == 1
        if @difference.nil?
          @payment_group.total
        else
          @payment_group.total + @difference
        end
      else
        @payment_group.total_euros
      end

    @view.number_to_currency(total, unit: @currency)
  end

  def services
    move_down 25
    text '<strong><u>Servicios incluidos en el pago: </u></strong>',
      size:          13,
      inline_format: true,
      align:         :left
    move_down 10
    services_table
  end

  def services_table
    method = (@report.printable_column == 1 ? 'amount' : 'euros')

    data = @payment_group.services.map do |service|
      date_in = service.date_in

      [
        service.reserve_id.to_s,
        (service.leg_ope.present? ? service.leg_ope : '-'),
        service.viajeroresponsable,
        (date_in.nil? ? '-' : date_in.strftime("%d/%m/%Y")),
        (service.provider ? service.provider.name : '-'),
        @view.number_to_currency(service.send(method), unit: @currency)
      ].compact
    end

    data.push(difference) if @difference

    data = [[
      "Reserva",
      "Localizador",
      "Titular",
      "Fecha In",
      "Prestador",
      "Importe"
    ]].concat(data)

    table(
      data,
      cell_style: {
        borders: [:top, :bottom, :left, :right],
        padding: 5,
        size:    11
      },
      column_widths: [90, 90, 90, 90, 90, 90]
    ) do |table|
      table.row(0).font_style = :bold
      table.row(0).padding    = 4
    end
  end

  def difference
    reserve =
      if @payment_group.payment.principal_reserve_id
        @payment_group.payment.principal_reserve_id.to_s
      else
        'EXCEDENTE (sin reserva asignada)'
      end

    diff =
      if @report.printable_column == 1
        @difference
      else
        @report.euros_difference
      end

    extra_data = [
      reserve,
      '',
      '',
      '',
      '',
      @view.number_to_currency(diff, unit: @currency)
    ].compact
  end

  def note
    return unless @report.note.present?

    move_down 25
    text "<strong><u>Nota: </u></strong>",
      size:          13,
      inline_format: true
    move_down 5
    text "<em>#{@report.note}</em>",
      inline_format:     true,
      indent_paragraphs: 15
  end

  def swift
    return unless @report.swift.present?

    move_down 25
    text "<strong><u>Swift: </u></strong>",
      size:          13,
      inline_format: true
    move_down 5
    text "<em>#{@report.swift}</em>",
      inline_format:     true,
      indent_paragraphs: 15
  end

end
