BaseService = require './base'

###*
 * Creates a new InventoryEntryService.
 * @class InventoryEntryService
###
class InventoryEntryService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a InventoryEntries API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/inventory'

###*
 * The {@link InventoryEntryService} service.
###
module.exports = InventoryEntryService
