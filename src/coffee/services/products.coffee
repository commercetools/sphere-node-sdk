BaseService = require './base'

###*
 * Creates a new ProductService.
 * @class ProductService
###
class ProductService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Products API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/products'

###*
 * The {@link ProductService} service.
###
module.exports = ProductService
