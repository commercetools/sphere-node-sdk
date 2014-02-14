BaseService = require './base'

###*
 * Creates a new TaxCategoryService.
 * @class TaxCategoryService
###
class TaxCategoryService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a TaxCategories API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/tax-categories'

###*
 * The {@link TaxCategoryService} service.
###
module.exports = TaxCategoryService
