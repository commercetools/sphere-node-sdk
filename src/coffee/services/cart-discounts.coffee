BaseService = require './base'

# Public: Define a `CartDiscountService` to interact with the HTTP [`cart-discounts`](http://dev.sphere.io/http-api-projects-cartDiscounts.html) endpoint.
#
# _Cart discounts are used to change the prices of different elements within a cart like Line Items._
#
# Examples
#
#   service = client.cartDisounts
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
class CartDiscountService extends BaseService

  # Internal: {String} The HTTP endpoint for `CartDiscounts`
  @baseResourceEndpoint: '/cart-discounts'

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

module.exports = CartDiscountService
