BaseService = require './base'

###*
 * Creates a new MessageService.
 * @class MessageService
###
class MessageService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Messages API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/messages'

###*
 * The {@link MessageService} service.
###
module.exports = MessageService
