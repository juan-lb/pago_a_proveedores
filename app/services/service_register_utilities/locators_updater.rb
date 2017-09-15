class LocatorsUpdater

  attr_reader :locators

  def initialize(params: nil, payment_group: nil)
    @params        = params
    @payment_group = payment_group
    @locators      = _locators
  end

  def call
    return false unless locators.any?

    locators.each { |data| update_service(data) }

    true
  end

  private

  def update_service(data)
    return unless data[:locator]

    Service.where(
      reserve_id:     data[:reserve_id],
      service_number: data[:service_number]
    ).update_all(
      leg_ope: data[:locator]
    )
  end

  def _locators
    conn = Connection.new(ENV['MO_SERVICES_URL'])
    res  = conn.get_locators services

    if res.status != 200
      []
    else
      res.body['body'].map do |each|
        file_number    = each.keys.first
        service_number = each[file_number].keys.first
        locator        = each[file_number][service_number]

        {
          reserve_id:     file_number,
          service_number: service_number,
          locator:        each[file_number][service_number]
        }
      end
    end
  end

  def services
    return @params unless @payment_group

    @payment_group.services.
      pluck(:reserve_id, :service_number).
      map do |attrs|
        {
          reserve_id:     attrs[0],
          service_number: attrs[1]
        }
      end
  end

end
