Rest = require('sphere-node-connect').Rest
ProductService = require('./services/products')

###*
 * Defines a SphereClient.
 * @class SphereClient
###
class SphereClient

  constructor: (config)->
    @_rest = new Rest config

    # services
    @products = new ProductService @_rest

###*
 * The {@link SphereClient} client.
###
module.exports = SphereClient