class Const
  COTIZATION = 10

  USD = 'U$D'
  ARS = 'AR$'

  PAYMENT_STATUS_DRAFT = 'Borrador'
  PAYMENT_STATUS_IN_PROCESS = 'En proceso'
  PAYMENT_STATUS_SENT = 'Enviado'
  PAYMENT_STATUS_CLOSED = 'Cargado'

  PAYMENT_STATUSES = {
    draft: PAYMENT_STATUS_DRAFT,
    in_process: PAYMENT_STATUS_IN_PROCESS,
    sent: PAYMENT_STATUS_SENT,
    closed: PAYMENT_STATUS_CLOSED
  }

  PER_PAGE = 30

  NATIONAL_ACCOUNT_CATEGORY = 'Nacional'
  INTERNATIONAL_ACCOUNT_CATEGORY = 'Internacional'
  NAT_INTER_ACCOUNT_CATEGORY = 'Nac/Inter'

  # Se usan para cargar el service_register. Ver service_register.rb -> set_near_expiring_date()
  FEC_SEN = 'fec_sen'
  FEC_PAG = 'fec_pag'
  FEC_SAL = 'fec_sal'
  FEC_OUT = 'fec_out'
  FEC_IN  = 'fec_in'

  # Retenciones ganancias
  IG_ALIQUOT = 1
  IG_LIMIT = 2000

  # Templates de Mandrill
  MANDRILL_PAYMENT_REPORT = 'aero-pap-reporte-de-pago'
  MANDRILL_STATISTICS_REPORT = 'aero-pap-reporte-de-estadisticas'
  MANDRILL_POSITIVES_BALANCES_REPORT = 'aero-pap-saldos-a-favor'
  MANDRILL_TRANSFERS_AVERAGE_REPORT = 'aero-pap-promedio-de-transferencias'

  # Texto por defecto en mail de reporte de pago
  PAYMENT_REPORT_MAIL_BODY = "Estimado proveedor, adjuntamos detalle de reservas abonadas el dia de hoy por trasferencia bancaria desde *. \nGracias,"
  SENT_PAYMENT_REPORT_MAIL_BODY = "Estimado proveedor, adjuntamos detalle de reservas abonadas el dia de hoy por trasferencia bancaria. \nGracias,"

  MONTHS = {
    1 => 'Enero',
    2 => 'Febrero',
    3 => 'Marzo',
    4 => 'Abril',
    5 => 'Mayo',
    6 => 'Junio',
    7 => 'Julio',
    8 => 'Agosto',
    9 => 'Septiembre',
    10 => 'Octubre',
    11 => 'Noviembre',
    12 =>  'Diciembre'
  }

  WEEK_DAYS = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ]

end
