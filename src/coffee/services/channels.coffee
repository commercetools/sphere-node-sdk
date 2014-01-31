BaseService = require('./base')

###*
 * Creates a new ChannelService.
 * @class ChannelService
###
class ChannelService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Channels API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/channels'

###*
 * The {@link ChannelService} service.
###
module.exports = ChannelService
