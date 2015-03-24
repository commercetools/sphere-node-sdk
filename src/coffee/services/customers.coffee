BaseService = require './base'

# Public: Define a `CustomerService` to interact with the HTTP [`customers`](http://dev.sphere.io/http-api-projects-customers.html) endpoint.
#
# _A customer is a person purchasing products. Carts, Orders, Comments and Reviews can be associated to a customer._
#
# Examples
#
#   service = client.customers()
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'changeName'
#           name:
#             en: 'Foo'
#         }
#       ]
class CustomerService extends BaseService

  # Internal: {String} The HTTP endpoint for `Customers`
  @baseResourceEndpoint: '/customers'

module.exports = CustomerService
