BaseService = require './base'

###*
 * Creates a new CategoryService.
 * @class CategoryService
###
class CategoryService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Customers API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/categories'

###*
 * The {@link CategoryService} service.
###
module.exports = CategoryService
