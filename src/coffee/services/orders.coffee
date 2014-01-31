BaseService = require('./base')

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
 * The {@link OrderService} service.
###
module.exports = OrderService
