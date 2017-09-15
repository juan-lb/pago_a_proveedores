class ApiProvider < ActiveResource::Base

  self.site = 'http://10.0.0.169:9092/api/v1'
  self.timeout = 200
  self.element_name = 'provider'

  self.headers['Authorization'] = 'Token token="afbadb4ff8485c0adcba486b4ca90cc4"'

end
