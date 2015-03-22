_ = require 'underscore'
Rest = require './connect/rest'
TaskQueue = require './task-queue'
CartDiscountService      = require './services/cart-discounts'
CartService              = require './services/carts'
CategoryService          = require './services/categories'
ChannelService           = require './services/channels'
CommentService           = require './services/comments'
CustomObjectService      = require './services/custom-objects'
CustomerService          = require './services/customers'
CustomerGroupService     = require './services/customer-groups'
DiscountCodeService      = require './services/discount-codes'
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

# Public: SphereClient - the official SDK
class SphereClient

  # Public: Construct a `SphereClient` object.
  #
  # options - An {Object} to configure the client
  constructor: (options = {}) ->

    # Private: instance of a {TaskQueue}
    @_task = options.task or new TaskQueue

    # Private: instance of a {Rest}
    @_rest = options.rest or new Rest _.defaults options, {user_agent: 'sphere-node-sdk'}

    # Private: wrapper to pass different options to new service instances
    _serviceOptions =
      _rest: @_rest
      _task: @_task
      _stats: _.defaults options.stats or {},
        includeHeaders: false

    # services
    # TODO: use functions to return new service instances?
    @cartDiscounts      = new CartDiscountService _serviceOptions
    @carts              = new CartService _serviceOptions
    @categories         = new CategoryService _serviceOptions
    @channels           = new ChannelService _serviceOptions
    @comments           = new CommentService _serviceOptions
    @customObjects      = new CustomObjectService _serviceOptions
    @customers          = new CustomerService _serviceOptions
    @customerGroups     = new CustomerGroupService _serviceOptions
    @discountCodes      = new DiscountCodeService _serviceOptions
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

  # Public: Define max parallel request to be sent on each request from the {TaskQueue}
  #
  # maxParallel - A {Number} between 1 and 100 (default is 20)
  setMaxParallel: (maxParallel) -> @_task.setMaxParallel maxParallel

module.exports = SphereClient
