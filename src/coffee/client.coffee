_ = require('underscore')._
{Rest} = require 'sphere-node-connect'
Logger = require './logger'
CartService              = require './services/carts'
CategoryService          = require './services/categories'
ChannelService           = require './services/channels'
CommentService           = require './services/comments'
CustomObjectService      = require './services/custom-objects'
CustomerService          = require './services/customers'
CustomerGroupService     = require './services/customer-groups'
InventoryService         = require './services/inventories'
OrderService             = require './services/orders'
ProductService           = require './services/products'
ProductProjectionService = require './services/product-projections'
ProductTypeService       = require './services/product-types'
ReviewService            = require './services/reviews'
ShippingMethodService    = require './services/shipping-methods'
TaxCategoryService       = require './services/tax-categories'

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
  constructor: (config) ->
    @logger = new Logger()
    ###*
     * @private
     * Instance of the Rest client
     * @type {Rest}
    ###
    @_rest = new Rest _.extend config,
      logConfig:
        logger: @logger

    # services
    # TODO: use functions to return new service instances?
    @carts              = new CartService @_rest
    @categories         = new CategoryService @_rest
    @channels           = new ChannelService @_rest
    @comments           = new CommentService @_rest
    @customObjects      = new CustomObjectService @_rest
    @customers          = new CustomerService @_rest
    @customerGroups     = new CustomerService @_rest
    @inventories        = new InventoryService @_rest
    @orders             = new OrderService @_rest
    @products           = new ProductService @_rest
    @productProjections = new ProductProjectionService @_rest
    @productTypes       = new ProductTypeService @_rest
    @reviews            = new ReviewService @_rest
    @shippingMethods    = new ShippingMethodService @_rest
    @taxCategories      = new TaxCategoryService @_rest

###*
 * The {@link SphereClient} client.
###
module.exports = SphereClient
