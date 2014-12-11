BaseService = require './base'

###*
 * Creates a new DiscountCodesService.
 * @class DiscountCodesService
###
class DiscountCodesService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a DiscountCodess API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/discount-codes'

###*
 * The {@link DiscountCodesService} service.
###
module.exports = DiscountCodesService
