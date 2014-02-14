BaseService = require './base'

###*
 * Creates a new CustomerGroupService.
 * @class CustomerGroupService
###
class CustomerGroupService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a CustomerGroups API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/customer-groups'

###*
 * The {@link CustomerGroupService} service.
###
module.exports = CustomerGroupService
