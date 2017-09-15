class Importation

  attr_accessor :wrong_reserves

  def initialize(registers)
    @connection        = Connection.new(ENV['APTOUR_URL'])
    @registers         = registers
    @service_registers = []
    @reserves          = []
    @wrong_agencies    = []
    @wrong_reserves    = []
  end

  def call(gateway = :auto, operator_aptour_id = -1)
    import = nil
    @import_all = operator_aptour_id == -1

    ActiveRecord::Base.transaction do
      import = Import.new(
        created_at:         DateTime.now,
        gateway:            gateway,
        operator_aptour_id: operator_aptour_id
      )

      delete_all operator_aptour_id
      process_services

      import.update wrong_reserves: @wrong_reserves

      if @import_all
        @connection.get_users.body.each do |user|
          User.create(
            aptour_id: user["ID_USU"],
            name:      user["NOM_USU"]
          )
        end
      end

    end

    import
  end

  private

  def process_services
    Rails.cache.delete(:agencies_data)

    @registers.each do |register|
      agency, traveller = register['NOMBRE'].split('/').map(&:strip)

      id_res                         = register['id_res']
      register['nombreagencia']      = agency
      register['viajeroresponsable'] = traveller
      register['status_service']     = 0
      register['operator_category']  = operators_categories[register['id_ope']]
      register['operator_aptour_id'] = register['id_ope']

      process_reserve id_res

      unless @wrong_reserves.include?(id_res)
        @service_registers << ServiceRegister.new(register)
        check_batch 1_000
      end
    end

    if @import_all
      importer = AgencyImporter.new
      importer.call(@reserves.map(&:agency_aptour_id).uniq)

      @wrong_agencies = importer.wrong_agencies
    end

    import_reserves
    check_batch 0

    ServiceRegister.
      where(id_res: @wrong_reserves).
      delete_all

    mark_services_added_to_payments
    update_old_services
  end

  def delete_all(operator_aptour_id)
    if operator_aptour_id == Import::ALL_OPERATORS
      ServiceRegister.delete_all
      Reserve.delete_all
      Agency.delete_all
      User.delete_all
    else
      ServiceRegister.where(
        operator_aptour_id: operator_aptour_id
      ).delete_all

      Reserve.where(
        reserve_id: @registers.map { |each| each['id_res'] }.uniq
      ).delete_all
    end
  end

  def process_reserve(reserve_id)
    return false if @reserves.map(&:reserve_id).include?(reserve_id)

    reserve = ReserveProcessor.new(reserve_id).call
    @reserves << reserve

    reserve
  end

  def import_reserves
    wrong_reserves = @reserves.select do |reserve|
      @wrong_agencies.include? reserve.agency_aptour_id
    end

    @wrong_reserves = wrong_reserves.map(&:reserve_id)
    @reserves      -= wrong_reserves

    set_agency_payments

    Reserve.import @reserves
  end

  def set_agency_payments
    paid = @connection.get_paid_by_agencies(
      @reserves.map(&:reserve_id)
    ).body

    @reserves.each do |reserve|
      amounts = paid[reserve.reserve_id.to_s]

      if amounts.nil?
        reserve.paid     = 0
        reserve.paid_usd = 0
      else
        reserve.paid     = amounts['importe'].to_f
        reserve.paid_usd = amounts['importeus'].to_f
      end

    end
  end

  def mark_services_added_to_payments
    query =
      ("UPDATE service_registers SR
        INNER JOIN services S ON
        SR.id_res = S.reserve_id
        AND SR.numero = S.service_number
        AND SR.operator_aptour_id = S.operator_aptour_id
        INNER JOIN payment_groups PG ON
        (PG.id = S.payment_group_id AND PG.status in ('Borrador', 'En proceso', 'Enviado'))
        set SR.marked = true;"
      )

    ActiveRecord::Base.connection.execute(query)
  end

  def update_old_services
    query =
      ("UPDATE services S
        INNER JOIN payment_groups PG ON
        (PG.id = S.payment_group_id AND PG.status in ('Borrador', 'En proceso'))
        LEFT JOIN service_registers SR ON
        SR.id_res = S.reserve_id AND SR.numero = S.service_number AND SR.operator_aptour_id = S.operator_aptour_id
        SET S.is_valid = false
        WHERE SR.id is null
        OR
        ((SR.dif_in_cents + SR.difus_in_cents) <> S.amount_in_cents AND S.is_valid);"
      )

    ActiveRecord::Base.connection.execute(query)
  end

  def registers_with_extra_data
    registers = @service_registers.select {|s| s.numero != 0}

    response = @connection.get_service_dates(
      registers.map { |r| r.slice(:id_res, :numero) }.compact
    ).body

    registers.each do |register|
      info = response["#{register.id_res}_#{register.numero}"]

      expiration = next_expiration(info, register)

      register.status_service          = info['id_status']
      register.obse_serv               = info['obse_serv']
      register.imp_sen                 = info['imp_sen']
      register.fec_sen                 = info['fec_sen']
      register.fec_pag                 = info['fec_pag']
      register.fec_in                  = info['fec_in']
      register.fec_out                 = info['fec_out']
      register.deta                    = info['deta']
      register.provider_aptour_id      = info['id_prestador']
      register.near_expiring_date_type = expiration[:type]
      register.near_expiring_date      = expiration[:date]
    end

    registers
  end

  def next_expiration(info, register)
    expiration = {
      Const::FEC_SEN => info["fec_sen"],
      Const::FEC_PAG => info["fec_pag"],
      Const::FEC_SAL => register.fec_sal,
      Const::FEC_OUT => info["fec_out"]
    }.
      compact.
      map { |k,v| [k, v.to_date] }.
      min { |each| each[1] }

    {
      type: expiration[0],
      date: expiration[1].to_date
    }
  end

  def check_batch(size)
    if @service_registers.size >= size
      registers_to_import = @service_registers.
        select { |r| r.numero == 0}

      registers_to_import += registers_with_extra_data

      ServiceRegister.import registers_to_import
      @service_registers = []
    end
  end

  def operators_categories
    return @categories if @categories

    @categories = {}

    Operator.select(:aptour_id, :category).each do |operator|
      @categories[operator.aptour_id] =
        if operator.category == 'undefined'
          'international'
        else
          operator.category
        end
    end

    @categories
  end

end
