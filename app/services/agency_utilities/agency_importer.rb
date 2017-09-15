class AgencyImporter

  attr_accessor :wrong_agencies

  def call(reserves_aptour_ids)
    data = ApiAgency.get_agencies(reserves_aptour_ids)

    @wrong_agencies = data.wrong || []

    agencies = data.agencies.map do |agency|
      Agency.new(
        name:      agency['text'],
        color:     agency['emision_aerotour_color'],
        aptour_id: agency['id_cliente_aptra']
      )
    end

    Agency.import agencies
  end

end
