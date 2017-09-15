class ServiceRegisterImporter

  def call(operator_id = 0)
    connection = Connection.new(ENV['APTOUR_URL'])
    setting    = Setting.take

    registers = connection.get_content(1.year.from_now, operator_id, '', 0, 0, '').body

    registers = registers.
      select { |register| eligible?(register, setting) }

    Rails.logger.info "Selección de registros: #{registers.count}"

    registers = registers.map do |reg|
      reg.except("cobradopes", "cobradodol", "pagadopes", "pagadodol", "adelantospes", "difpes", "difdol")
    end

    registers
  end

  private

  def eligible?(register, setting)
    return false unless operators_ids.include?(register["id_ope"])

    if (register["dif"].to_d < 0 || register["difus"].to_d < 0)
      eligible_credit?(register, setting)
    else
      eligible_debit?(register)
    end

  end

  def eligible_credit?(register, setting)
    (register["dif"].to_d <= setting.max_ars_credit_dif ||
     register["difus"].to_d <= setting.max_usd_credit_dif) &&
      (register["fec_sal"].to_date > 1.year.ago.to_date)
  end

  def eligible_debit?(register)
    (register["dif"].to_d >= 10 || register["difus"].to_d >= 1) &&
     register["fec_sal"].to_date > 1.year.ago.to_date
  end

  def operators_ids
    @operators ||= Operator.pluck(:aptour_id)
  end

end
