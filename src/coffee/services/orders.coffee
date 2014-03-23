BaseService = require './base'

###*
 * Creates a new OrderService.
 * @class OrderService
###
class OrderService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Orders API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/orders'

  ###*
   * Creates directly an Order by importing it instead of creating it from a Cart.
   * @param {Object} body The payload as JSON object
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  import: (body) ->
    @_currentEndpoint = '/orders/import'
    @save(body)

###*
 * The {@link OrderService} service.
###
module.exports = OrderService
