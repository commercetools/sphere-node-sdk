BaseService = require './base'

###*
 * Creates a new StateService.
 * @class StateService
###
class StateService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a States API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/states'

###*
 * The {@link StateService} service.
###
module.exports = StateService
