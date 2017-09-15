class ServiceRegisterDecorator < Draper::Decorator
  delegate_all

  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::DateHelper

  def amount_with_currency
    "#{currency}  #{amount}"
  end

  def amount
    total = service_register.dif == 0 ? service_register.difus : service_register.dif
    number_with_precision(total)
  end

  def currency
    service_register.moneda == 'P' ? Const::ARS : Const::USD
  end

  def passenger
    return '-' unless service_register.viajeroresponsable

    truncate(service_register.viajeroresponsable.upcase, length: 20)
  end

  def reserve_services
    reserve.service_registers.where(id_ope: service_register.id_ope).size
  end

  def reserve
    service_register.reserve
  end

  def agency_color
    if reserve.agency
      reserve.agency.agency_color
    else
      'default'
    end
  end

  def agency_name
    if reserve.agency
      truncate(reserve.agency.name, length: 20)
    else
      '-'
    end
  end

  def agency_payment_ars
    reserve.paid.abs
  end

  def agency_payment_usd
    reserve.paid_usd.abs
  end

  def has_detail?
    service_register.DET_PREV.blank?
  end

  def short_status
    truncate(status, length: 10)
  end

  def status
    # TODO: revisar si el estado del serivico es obligatorio. Esto se cambió porque vino un service_register con status_service en nil
    ServiceRegister::STATES.detect { |state| state.include?(service_register.status_service)}.try(:first)  || '-'
  end

  def fec_sal
    I18n.l(service_register.fec_sal.to_date)
  end

  def fec_pag
    service_register.fec_pag.nil? ? '-' : I18n.l(service_register.fec_pag.to_date)
  end

  def fec_sen
    service_register.fec_sen.nil? ? '-' : I18n.l(service_register.fec_sen.to_date)
  end

  def fec_out
    service_register.fec_out.nil? ? '-' : I18n.l(service_register.fec_out.to_date)
  end

  private

  def service_register
    object
  end

  def statuses
    [
      "Borrador", "Confirmado",
      "Hacer", "Requerido",
      "Cancelado", "", "",
      "Pedido para cancelar"
    ]
  end

end
