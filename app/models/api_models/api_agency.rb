class ApiAgency < ActiveResource::Base
  require 'net/http'

  # self.site = ENV['AGENCY_API_URL']
  self.site = 'http://10.0.0.169:9093/api/v1'
  self.timeout = 200
  self.element_name = 'agency'
  self.headers['Authorization'] = 'Token token="afbadb4ff8485c0adcba486b4ca90cc4"'

  def self.get_agencies(ids)
    agencies = get_all.
      select { |agency| ids.include? agency['id_cliente_aptra'] }

    imported_ids = agencies.
      map { |agency| agency['id_cliente_aptra'] }

    Struct.new(:agencies, :wrong).
      new(agencies, ids - imported_ids)
  end

  private

  def self.get_all
    url = File.join(site.to_s, 'agencies/index_with_state')

    JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)
  end

end
