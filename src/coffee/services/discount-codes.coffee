BaseService = require './base'

# Public: Define a `DiscountCodeService` to interact with the HTTP [`discount-codes`](http://dev.sphere.io/http-api-projects-discountCodes.html) endpoint.
#
# _Discount codes can be added to a cart to enable certain cart discounts._
#
# Examples
#
#   service = client.discountCodes()
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
class DiscountCodeService extends BaseService

  # Internal: {String} The HTTP endpoint for `DiscountCodes`
  @baseResourceEndpoint: '/discount-codes'

module.exports = DiscountCodeService
