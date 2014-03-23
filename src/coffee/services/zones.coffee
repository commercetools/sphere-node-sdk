BaseService = require './base'

###*
 * Creates a new ZoneService.
 * @class ZoneService
###
class ZoneService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Zones API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/zones'

###*
 * The {@link ZoneService} service.
###
module.exports = ZoneService
