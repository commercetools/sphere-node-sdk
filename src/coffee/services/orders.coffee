BaseService = require './base'

# Public: Define a `OrderService` to interact with the HTTP [`orders`](http://dev.sphere.io/http-api-projects-orders.html) endpoint.
#
# _An order is the final state of a cart, usually created after a checkout process has been completed._
#
# Examples
#
#   service = client.orders()
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'changeOrderState'
#           orderState: 'Complete'
#         }
#       ]
class OrderService extends BaseService

  # Internal: {String} The HTTP endpoint for `Orders`
  @baseResourceEndpoint: '/orders'

  ###*
   * Creates directly an Order by importing it instead of creating it from a Cart.
   * @param {Object} body The payload as JSON object
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###

  # Public: Create directly an `Order` by importing it instead of creating it from a `Cart`.
  #
  # body - {Object} The payload described by the related API resource as JSON
  #
  # Throws an {Error} if `body` is missing
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {Error}
  #
  # Examples
  #
  #   service = client.orders()
  #   service.import
  #     orderNumber: 'a-123'
  #     customerId: '111'
  #     customerEmail: 'john@doe.com'
  #     lineItems: [
  #       {
  #         productId: '222'
  #         variant:
  #           id: 3
  #           sku: 'foo-1'
  #         price:
  #           value:
  #             currencyCode: 'EUR'
  #             centAmount: 1000
  #           country: 'de'
  #         quantity: 5
  #         taxRate:
  #           id: '333'
  #           name: '19%'
  #           amount: 0.19
  #           country: 'de'
  #       }
  #     ]
  #     totalPrice:
  #       currencyCode: 'EUR'
  #       centAmount: 1500
  #     taxedPrice
  #       currencyCode: 'EUR'
  #       centAmount: 500
  #     shippingAddress:
  #       firstName: 'John'
  #       lastName: 'Doe'
  #       country: 'de'
  #     orderState: 'Open'
  #     completedAt: '2001-09-11T14:00:00.000Z'
  import: (body) ->
    endpoint = '/orders/import'
    unless body
      throw new Error "Body payload is required for creating a resource (endpoint: #{endpoint})"
    @_save(endpoint, body)

  # Public: Not supported by the API
  delete: ->

module.exports = OrderService
