Rest = require('sphere-node-connect').Rest
CategoryService    = require('./services/categories')
OrderService       = require('./services/orders')
ProductService     = require('./services/products')
ProductTypeService = require('./services/product-types')

###*
 * Defines a SphereClient.
 * @class SphereClient
###
class SphereClient

  ###*
   * Constructs a new client with given API credentials
   * @constructor
   *
   * @param {Object} [config] An object containing the credentials for the `sphere-node-connect`
   * {@link https://github.com/emmenko/sphere-node-connect#documentation}
  ###
  constructor: (config)->
    ###*
     * @private
     * Instance of the Rest client
     * @type {Rest}
    ###
    @_rest = new Rest config

    # services
    @categories   = new CategoryService @_rest
    @orders       = new OrderService @_rest
    @products     = new ProductService @_rest
    @productTypes = new ProductTypeService @_rest

###*
 * The {@link SphereClient} client.
###
module.exports = SphereClient
