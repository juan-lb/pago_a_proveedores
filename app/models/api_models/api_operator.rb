class ApiOperator < ActiveResource::Base

  # self.site = ENV["OPERATOR_API_URL"]
  self.site = 'http://10.0.0.169:9092/api/v1'
  self.timeout = 200
  self.element_name = 'operator'

  self.headers['Authorization'] = 'Token token="afbadb4ff8485c0adcba486b4ca90cc4"'

  def self.not_aerials
    self.
      get(:index_with_accounts).
      reject { |each| each['id_cat2'] == 3}
  end

end
