class ReserveProcessor

  attr_accessor :reserve, :agency

  def initialize(reserve_id)
    @reserve_id = reserve_id
    @connection = Connection.new(ENV["APTOUR_URL"])
  end

  def call
    Reserve.new(
      reserve_id:       @reserve_id,
      agency_aptour_id: reserve_data[:id_cli],
      observations:     reserve_data[:obse],
      fec_ape:          reserve_data[:fec_ape],
      id_usu:           reserve_data[:id_usu],
      id_operes:        reserve_data[:id_operes],
      debt:             debt     || 0.0,
      debt_usd:         debt_usd || 0.0,
      client_details:   reserve_data[:detalle_viaje]
    )
  end

  def reserve_data
    @reserve_data ||= @connection.
      get_reserve(@reserve_id).body.deep_symbolize_keys
  end

  def debt
    services.
      select    { |each| each['moneda'] == 'P' }.
      inject(0) { |sum, each| sum + each['costo'].to_f }
  end

  def debt_usd
    services.
      select    { |each| each['moneda'] == 'D' }.
      inject(0) { |sum, each| sum + each['costous'].to_f }
  end

  def services
    @services ||= @connection.get_reserve_services(@reserve_id).body
  end

end
