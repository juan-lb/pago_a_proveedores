class IgRetentionPdf < Prawn::Document

  include ActionView::Helpers::NumberHelper

  def initialize(payment_group, view)
    super()
    @payment_group = payment_group
    @view = view
    @operator = payment_group.operator
    @ig_retention = IgRetention.find_by(operator_aptour_id: @operator.aptour_id)
    @setting = Setting.first
    @total = set_total
    header()
    retention_agent()
    retention_subject()
    amounts()
  end

  def logo
    logopath = "#{Rails.root}/app/assets/images/logo.png"
    image logopath, width: 197, height: 91
  end

  def header
    move_down 10
    text "#{@payment_group.updated_at.strftime("%d/%m/%Y")}", indent_paragraphs: 430
    text "<b>Nro de pago:</b> #{@payment_group.id}", indent_paragraphs: 430, inline_format: true
    move_down 15
    text "<u>Constancia de Retención Impuesto a las Ganancias (Res. Gral 830/00)</u>", size: 14, inline_format: true
  end

  def retention_agent
    move_down 15
    text "<b>Agente de retención:</b> AERO S.R.L.", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "48 Nro 630 5to F", indent_paragraphs: 140
    move_down 5
    text "30-70736214-2", indent_paragraphs: 140
  end

  def retention_subject
    move_down 10
    text "<b>Sujeto retenido:</b> #{@operator.business_name || @operator.name}", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "#{@operator.address}", indent_paragraphs: 115
    move_down 5
    text "#{@operator.cuit}", indent_paragraphs: 115
  end

  def amounts
    move_down 10
    text "<b>Impuesto:</b> Impuesto a las Ganancias", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "<b>Regimen:</b> Locaciones de obra y/o Servicios no ejecutados en relación de dependencia", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "<b>Importe de la operación  (AR$):</b> #{number_to_currency @total}", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "<b>Acumulado mensual  (AR$):</b> #{number_to_currency @ig_retention.accumulated}", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "<b>Base imponible  (AR$):</b> #{number_to_currency get_base_imponible()}", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "<b>Alicuota  (%):</b> #{@setting.ig_aliquot}", indent_paragraphs: 20, inline_format: true
    move_down 5
    text "<b>Importe retenido (AR$): </b> #{number_to_currency @payment_group.payment.ig_retention * @payment_group.payment.cotization}", indent_paragraphs: 20, inline_format: true
  end

  def get_base_imponible
    cotization = (@payment_group.currency == 'D') ? @payment_group.payment.cotization : 1
    if @ig_retention.accumulated >= @setting.ig_limit
      @payment_group.payment.total_debt * cotization
    else
      difference = @setting.ig_limit - @ig_retention.accumulated
      difference_debt = (@payment_group.payment.total_debt * cotization) - difference
      difference_debt.round 2
    end
  end

  private

  def set_total
    if @payment_group.currency_symbol != 'AR$'
      total = (@payment_group.payment.total_payment + @payment_group.payment.ig_retention) * @payment_group.payment.cotization
    else
      total = @payment_group.payment.total_payment
    end
    total = total.round 2
  end

end
