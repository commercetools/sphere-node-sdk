BaseService = require('./base')

###*
 * Creates a new CartService.
 * @class CartService
###
class CartService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Carts API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/carts'

###*
 * The {@link CartService} service.
###
module.exports = CartService
