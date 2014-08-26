BaseService = require './base'

###*
 * Creates a new ProjectService.
 * @class ProjectService
###
class ProjectService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Project API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: ''

###*
 * The {@link ProjectService} service.
###
module.exports = ProjectService
