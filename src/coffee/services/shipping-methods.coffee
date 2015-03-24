BaseService = require './base'

# Public: Define a `ShippingMethodService` to interact with the HTTP [`shipping-methods`](http://dev.sphere.io/http-api-projects-shippingMethods.html) endpoint.
#
# _Shipping Methods define where orders can be shipped and what the costs are._
#
# Examples
#
#   service = client.shippingMethods()
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
class ShippingMethodService extends BaseService

  # Internal: {String} The HTTP endpoint for `ShippingMethods`
  @baseResourceEndpoint: '/shipping-methods'

  # Public Unsupported: Not supported by the API
  delete: ->

module.exports = ShippingMethodService
