BaseService = require './base'

# Login service as defined in http://dev.sphere.io/http-api-projects-customers.html#authenticate-customer
class AuthenticationService extends BaseService

  # Internal: {String} The HTTP endpoint for `Authentication`
  @baseResourceEndpoint: '/login'

module.exports = AuthenticationService
