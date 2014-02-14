BaseService = require './base'

###*
 * Creates a new CustomerService.
 * @class CustomerService
###
class CustomerService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Customers API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/customers'

###*
 * The {@link CustomerService} service.
###
module.exports = CustomerService
