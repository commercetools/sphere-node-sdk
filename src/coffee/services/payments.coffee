BaseService = require './base'

# Public: Define a `PaymentService` to interact with the HTTP [`payments`](http://dev.sphere.io/http-api-projects-payments.html) endpoint.
#
# _Payments hold the state of payments made with an external system (PSP) and may store interactions with it._
#
# Examples
#
#   service = client.payments
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'setAmountPaid'
#           amount:
#            centAmount: 20500,
#            currencyCode: 'EUR'
#         }
#       ]
class PaymentService extends BaseService

  # Internal: {String} The HTTP endpoint for `Payments`
  @baseResourceEndpoint: '/payments'

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

module.exports = PaymentService
