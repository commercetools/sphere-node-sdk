_ = require 'underscore'
{Rest} = require 'sphere-node-connect'
{TaskQueue} = require 'sphere-node-utils'
Logger = require './logger'
CartService              = require './services/carts'
CategoryService          = require './services/categories'
ChannelService           = require './services/channels'
CommentService           = require './services/comments'
CustomObjectService      = require './services/custom-objects'
CustomerService          = require './services/customers'
CustomerGroupService     = require './services/customer-groups'
InventoryEntryService    = require './services/inventory-entries'
MessageService           = require './services/messages'
OrderService             = require './services/orders'
ProductService           = require './services/products'
ProductProjectionService = require './services/product-projections'
ProductTypeService       = require './services/product-types'
ReviewService            = require './services/reviews'
ShippingMethodService    = require './services/shipping-methods'
StateService             = require './services/states'
TaxCategoryService       = require './services/tax-categories'
ZoneService              = require './services/zones'

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
   * {@link https://github.com/sphereio/sphere-node-connect#documentation}
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
     * Instance of a TaskQueue
     * @type {TaskQueue}
    ###
    @_task = options.task or new TaskQueue

    ###*
     * @private
     * Instance of the Rest client
     * @type {Rest}
    ###
    @_rest = options.rest or new Rest _.extend options,
      logConfig:
        logger: @_logger

    # services
    # TODO: use functions to return new service instances?
    @carts              = new CartService @_rest, @_logger, @_task
    @categories         = new CategoryService @_rest, @_logger, @_task
    @channels           = new ChannelService @_rest, @_logger, @_task
    @comments           = new CommentService @_rest, @_logger, @_task
    @customObjects      = new CustomObjectService @_rest, @_logger, @_task
    @customers          = new CustomerService @_rest, @_logger, @_task
    @customerGroups     = new CustomerGroupService @_rest, @_logger, @_task
    @inventoryEntries   = new InventoryEntryService @_rest, @_logger, @_task
    @messages           = new MessageService @_rest, @_logger, @_task
    @orders             = new OrderService @_rest, @_logger, @_task
    @products           = new ProductService @_rest, @_logger, @_task
    @productProjections = new ProductProjectionService @_rest, @_logger, @_task
    @productTypes       = new ProductTypeService @_rest, @_logger, @_task
    @reviews            = new ReviewService @_rest, @_logger, @_task
    @shippingMethods    = new ShippingMethodService @_rest, @_logger, @_task
    @states             = new StateService @_rest, @_logger, @_task
    @taxCategories      = new TaxCategoryService @_rest, @_logger, @_task
    @zones              = new ZoneService @_rest, @_logger, @_task

###*
 * The {@link SphereClient} client.
###
module.exports = SphereClient
