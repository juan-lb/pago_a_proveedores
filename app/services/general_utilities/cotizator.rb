class Cotizator

  API_URL = ENV['CURRENCY_API_URL']

  def usd_cotization
    conn = Connection.new(API_URL)
    result = conn.get_usd_cotization.body
    result.present? ? result['value'].to_f : :currency_api_error
  end

  def eur_cotization
    conn = Connection.new(API_URL)
    result = conn.get_eur_cotization.body
    result.present? ? result['value'].to_f : :currency_api_error
  end

end
