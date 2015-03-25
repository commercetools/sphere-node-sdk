BaseService = require './base'

# Public: Define a `ProductDiscountService` to interact with the HTTP [`customers`](http://dev.sphere.io/http-api-projects-productDiscounts.html) endpoint.
#
# _Product discounts are used to change certain product prices._
#
# Examples
#
#   service = client.productDiscounts
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
class ProductDiscountService extends BaseService

  # Internal: {String} The HTTP endpoint for `ProductDiscounts`
  @baseResourceEndpoint: '/product-discounts'

module.exports = ProductDiscountService
