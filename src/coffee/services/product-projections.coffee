_ = require 'underscore'
BaseService = require './base'

###*
 * Creates a new ProductProjectionService.
 * @class ProductProjectionService
###
class ProductProjectionService extends BaseService

  _staged = false

  ###*
   * @const
   * @private
   * Base path for a ProductProjections API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/product-projections'

  ###*
   * Define to fetch only staged products
   * @param Boolean [queryStaged] true to query staged products (default). False to query published products
   * @return {ProductProjectionService} Chained instance of this class
  ###
  staged: (queryStaged = true) ->
    @_staged = queryStaged
    this

  ###*
   * @private
   * Extend the query string by staged param
   * @return {String} the query string
  ###
  _queryString: ->
    s = super
    return _.compact([s, "staged=#{@_staged}"]).join('&') if @_staged
    s


###*
 * The {@link ProductProjectionService} service.
###
module.exports = ProductProjectionService
