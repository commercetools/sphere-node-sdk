BaseService = require './base'

# Public: Define a `CartService` to interact with the HTTP [`carts`](http://dev.sphere.io/http-api-projects-carts.html) endpoint.
#
# _A shopping cart holds product variants and can be turned into an order.
# Each cart either belongs to a registered customer or it is an anonymous cart._
#
# Examples
#
#   service = client.carts
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'addLineItem'
#           productId: '111'
#           variantId: 2
#           quantity: 1
#         }
#       ]
class CartService extends BaseService

  # Internal: {String} The HTTP endpoint for `Carts`
  @baseResourceEndpoint: '/carts'

module.exports = CartService
