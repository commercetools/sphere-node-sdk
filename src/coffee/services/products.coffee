BaseService = require('./base')

###*
 * Creates a new ProductService.
 * @class ProductService
###
class ProductService extends BaseService

  ###*
   * Initialize the class.
   * @param  {Rest} [_rest] an instance of the Rest client (sphere-node-connect)
   * @return {ProductService}
  ###
  constructor: (rest)->
    super(rest)
    @_projectEndpoint = '/'

###*
 * The {@link ProductService} service.
###
module.exports = ProductService