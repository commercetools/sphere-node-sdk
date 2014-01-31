BaseService = require('./base')

###*
 * Creates a new InventoryService.
 * @class InventoryService
###
class InventoryService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Inventories API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/inventory'

###*
 * The {@link InventoryService} service.
###
module.exports = InventoryService
