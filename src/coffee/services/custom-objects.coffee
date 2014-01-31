BaseService = require('./base')

###*
 * Creates a new CustomObjectService.
 * @class CustomObjectService
###
class CustomObjectService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a CustomObjects API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/custom-objects'

###*
 * The {@link CustomObjectService} service.
###
module.exports = CustomObjectService
