BaseService = require './base'

###*
 * Creates a new CartDiscountService.
 * @class CartDiscountService
###
class CartDiscountService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a CartDiscounts API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/cart-discounts'

###*
 * The {@link CartDiscountService} service.
###
module.exports = CartDiscountService
