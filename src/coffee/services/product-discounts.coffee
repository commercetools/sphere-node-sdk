BaseService = require './base'

###*
 * Creates a new ProductDiscountService.
 * @class ProductDiscountService
###
class ProductDiscountService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a ProductDiscounts API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/product-discounts'

###*
 * The {@link ProductDiscountService} service.
###
module.exports = ProductDiscountService
