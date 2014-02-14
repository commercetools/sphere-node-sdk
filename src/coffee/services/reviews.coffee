BaseService = require './base'

###*
 * Creates a new ReviewService.
 * @class ReviewService
###
class ReviewService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Reviews API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/reviews'

###*
 * The {@link ReviewService} service.
###
module.exports = ReviewService
