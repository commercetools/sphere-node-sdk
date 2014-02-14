BaseService = require './base'

###*
 * Creates a new ShippingMethodService.
 * @class ShippingMethodService
###
class ShippingMethodService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a ShippingMethods API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/shipping-methods'

###*
 * The {@link ShippingMethodService} service.
###
module.exports = ShippingMethodService
