BaseService = require './base'

# Login service as defined in http://dev.sphere.io/http-api-projects-customers.html#authenticate-customer
#
# Example
#   service = client.authentication
#   service.save
#     email: "test@test.com"
#     password: "1234"
#
class AuthenticationService extends BaseService

  # Internal: {String} The HTTP endpoint for `Authentication`
  @baseResourceEndpoint: '/login'

module.exports = AuthenticationService
