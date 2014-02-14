BaseService = require './base'

###*
 * Creates a new ProductTypeService.
 * @class ProductTypeService
###
class ProductTypeService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a ProductTypes API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/product-types'

###*
 * The {@link ProductTypeService} service.
###
module.exports = ProductTypeService
