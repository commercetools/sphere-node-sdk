_ = require 'underscore'
{Rest} = require 'sphere-node-connect'
Logger = require './logger'
CartService              = require './services/carts'
CategoryService          = require './services/categories'
ChannelService           = require './services/channels'
CommentService           = require './services/comments'
CustomObjectService      = require './services/custom-objects'
CustomerService          = require './services/customers'
CustomerGroupService     = require './services/customer-groups'
InventoryEntryService    = require './services/inventory-entries'
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
   * @param {Object} [options] An object containing the credentials for the `sphere-node-connect`
   * {@link https://github.com/emmenko/sphere-node-connect#documentation}
  ###
  constructor: (options = {}) ->
    ###*
     * @private
     * Instance of a Logger
     * @type {Logger}
    ###
    @_logger = new Logger options.logConfig

    ###*
     * @private
     * Instance of the Rest client
     * @type {Rest}
    ###
    @_rest = new Rest _.extend options,
      logConfig:
        logger: @_logger

    # services
    # TODO: use functions to return new service instances?
    @carts              = new CartService @_rest, @_logger
    @categories         = new CategoryService @_rest, @_logger
    @channels           = new ChannelService @_rest, @_logger
    @comments           = new CommentService @_rest, @_logger
    @customObjects      = new CustomObjectService @_rest, @_logger
    @customers          = new CustomerService @_rest, @_logger
    @customerGroups     = new CustomerGroupService @_rest, @_logger
    @inventoryEntries   = new InventoryEntryService @_rest, @_logger
    @orders             = new OrderService @_rest, @_logger
    @products           = new ProductService @_rest, @_logger
    @productProjections = new ProductProjectionService @_rest, @_logger
    @productTypes       = new ProductTypeService @_rest, @_logger
    @reviews            = new ReviewService @_rest, @_logger
    @shippingMethods    = new ShippingMethodService @_rest, @_logger
    @taxCategories      = new TaxCategoryService @_rest, @_logger

###*
 * The {@link SphereClient} client.
###
module.exports = SphereClient
