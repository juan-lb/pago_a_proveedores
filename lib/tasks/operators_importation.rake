namespace :operators_importation do
  desc "Acomoda service_registers, services e ig_retention viejos para mantener integridad"
  task import_all: :environment do
    ActiveRecord::Base.transaction do

      puts "---------Importando operadores---------"
      OperatorImportation.new.call
      puts "---------Terminó de importar operadores----------"

      puts "---------Actualizando service_registers---------"
      update_service_registers
      puts "---------Terminó de actualizar service_registers----------"

      puts "---------Actualizando ig_retentions----------"
      update_ig_retentions
      puts "---------Terminó de actualizar ig_retentions----------"

      puts "---------Actualizando pagos----------"
      update_payment_groups
      puts "---------Terminó de actualizar pagos----------"

      puts "---------Actualizando servicios----------"
      update_services
      puts "---------Terminó de actualizar servicios----------"

      # OJO: ESTE SÓLO EJECUTARLO SI SE USO UN DUMP DE LA DB VIEJA
      # (LA DE PRODUCCIÓN PREVIA A LA ACTUALZIACIÓN)
      # Y LUEGOOOOOOO DE CORRERLO, VOLVER A MODIFICAR LA LÍNEA DEL
      # ARCHIVO RESERVE.RB
      # puts "---------Actualizando reservas para coincidir agencias----------"
      # update_reserves()
      # puts "---------Terminó de actualizar reservas----------"
    end
  end

  # Actualiza los service_registers para actualizar el operator_aptour_id
  def update_service_registers
    ServiceRegister.update_all('operator_aptour_id = id_ope')
  end

  # Actualiza las retenciones de ganancias para actualizar el operator_aptour_id
  def update_ig_retentions
    IgRetention.update_all('operator_aptour_id = id_ope')
  end

  # Actualiza los pagos para actualizar el operator_aptour_id
  def update_payment_groups
    PaymentGroup.update_all('operator_aptour_id = operator_id')
  end

  # Actualiza los servicios para actualizar el operator_aptour_id
  def update_services
    Service.update_all('operator_aptour_id = operator_id')
  end

  # Actualiza las reservas para que en agency_aptour_id tenga el aptour_id
  # de la agencia (en vez del id de la DB local).
  # PARA QUE FUNCIONE, ES NECESARIO QUE SE MODIFIQUE UNA LÍNEA
  # DEL ARCHIVO RESERVE.RB:
  # belongs_to :agency, primary_key: 'aptour_id',
  # foreign_key: 'agency_aptour_id'
  # DEBE CAMBIAR POR:
  # belongs_to :agency, foreign_key: 'agency_aptour_id'
  def update_reserves
    Reserve.all.each do |reserve|
      reserve.update(agency_aptour_id: reserve.agency.aptour_id)
    end
  end

end
