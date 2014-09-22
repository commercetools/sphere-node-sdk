_ = require 'underscore'
Rest = require './connect/rest'
TaskQueue = require './task-queue'
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
ProductDiscountService   = require './services/product-discounts'
ProductService           = require './services/products'
ProductProjectionService = require './services/product-projections'
ProductTypeService       = require './services/product-types'
ProjectService           = require './services/project'
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
     * Instance of a Logger object
     * @type {Logger}
    ###
    @_logger = new Logger options.logger

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
      logger: @_logger

    ###*
     * @private
     * Wrapper to pass different options to new service instances
     * @type {Object}
    ###
    _serviceOptions =
      _rest: @_rest
      _task: @_task
      _logger: @_logger
      _stats: _.defaults options.stats or {},
        includeHeaders: false

    # services
    # TODO: use functions to return new service instances?
    @carts              = new CartService _serviceOptions
    @categories         = new CategoryService _serviceOptions
    @channels           = new ChannelService _serviceOptions
    @comments           = new CommentService _serviceOptions
    @customObjects      = new CustomObjectService _serviceOptions
    @customers          = new CustomerService _serviceOptions
    @customerGroups     = new CustomerGroupService _serviceOptions
    @inventoryEntries   = new InventoryEntryService _serviceOptions
    @messages           = new MessageService _serviceOptions
    @orders             = new OrderService _serviceOptions
    @products           = new ProductService _serviceOptions
    @productDiscounts   = new ProductDiscountService _serviceOptions
    @productProjections = new ProductProjectionService _serviceOptions
    @productTypes       = new ProductTypeService _serviceOptions
    @project            = new ProjectService _serviceOptions
    @reviews            = new ReviewService _serviceOptions
    @shippingMethods    = new ShippingMethodService _serviceOptions
    @states             = new StateService _serviceOptions
    @taxCategories      = new TaxCategoryService _serviceOptions
    @zones              = new ZoneService _serviceOptions

  ###*
   * Define max parallel request to be sent on each request from the {TaskQueue}
   * @param {Number} maxParallel A number between 1 and 100 (default is 20)
  ###
  setMaxParallel: (maxParallel) -> @_task.setMaxParallel maxParallel

###*
 * The {@link SphereClient} client.
###
module.exports = SphereClient
