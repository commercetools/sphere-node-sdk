BaseService = require('./base')

###*
 * Creates a new ProductService.
 * @class ProductService
###
class ProductService extends BaseService

  ###*
   * Initialize the class.
   * @constructor
   *
   * @param  {Rest} [_rest] An instance of the Rest client `sphere-node-connect`
  ###
  constructor: (rest)->
    super(rest)
    ###*
     * @private
     * Base path for Products endpoint.
     * @type {String}
    ###
    @_projectEndpoint = '/products'

###*
 * The {@link ProductService} service.
###
module.exports = ProductService