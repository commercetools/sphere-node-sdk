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

# Public: The `SphereClient` provides a set of Services to connect with the related API endpoints.
# To configure the underlying Http client see {Rest}
#
# ```coffeescript
# SphereClient = require('sphere-node-sdk').SphereClient
# ```
#
# Requests to the HTTP API are obviously asynchronous and they all return a {Promise}.
# If the request is resolved, the `result` contains:
# - `statusCode`
# - `body`
# If the request is rejected, the `error` is an instance of a {HttpError} or a {SphereError}.
#
# When a promise is rejected, the response object contains a field `originalRequest`,
# providing some information about the related request (`endpoint`, `payload`).
# This is useful to better understand the error in relation with the failed request.
#
# ### TaskQueue
# To optimize processing lots of requests all together, e.g.: avoiding connection timeouts, we introduced {TaskQueue}.
# Every request is internally pushed in a queue which automatically starts resolving promises (requests)
# and will process concurrently some of them based on the `maxParallel` parameter. You can set this parameter by calling {::setMaxParallel}.
#
# ```coffeescript
# client = new SphereClient # a TaskQueue is internally initialized at this point with maxParallel of 20
# client.setMaxParallel 5
#
# # let's trigger 100 parallel requests with `Promise.all`, but process them max 5 at a time
# Promise.all _.map [1..100], -> client.products.byId('123-abc').fetch()
# .then (results) ->
# ```
#
# ### Error handling
# As the HTTP API _gracefully_ handles errors by providing a JSON body with error codes and messages,
# the `SphereClient` handles that by providing an intuitive way of dealing with responses.
#
# Since a {Promise} can be either `resolved` or `rejected`, the result is determined by valuating the `statusCode` of the response:
# - `resolved` everything with a successful HTTP status code
# - `rejected` everything else
#
# ### Error types
# All SPHERE.IO response _errors_ are then wrapped in a custom {Error} type (either a {HttpError} or {SphereError})
# and returned as a rejected {Promise} value. That means you can do type check as well as getting the JSON response body.
#
# ```coffeescript
# Errors = require('sphere-node-sdk').Errors
# client.products().byId(productId).update(payload)
# .then (result) ->
#   # we know the request was successful (e.g.: 2xx) and `result` is a JSON of a resource representation
# .catch (e) ->
#   # something went wrong, either an unexpected error or a HTTP API error response
#   # here we can check the error type to differentiate the error
#   if e instanceof Errors.SphereHttpError.ConcurrentModification
#     # e.code => 409
#     # e.message => 'Different version then expected'
#     # e.body => statusCode: 409, message: ...
#     # e instanceof SphereError => true
#   else
#     throw e
# ```
#
# Following error types are exposed:
# - `{HttpError}`
# - `{SphereError}`
# - `SphereHttpError`
#   - `{BadRequest}`
#   - `{NotFound}`
#   - `{ConcurrentModification}`
#   - `{InternalServerError}`
#   - `{ServiceUnavailable}`
#
# ### Statistics
# Some statistics (more to come) are provided by passing some options when creating a new `SphereClient` instance.
#
# Current options are available:
# - `includeHeaders` will include some HTTP header information in the response, wrapped in a JSON object called `http`
#
# ```coffeescript
# client = new SphereClient
#   config: # credentials
#   stats:
#     includeHeaders: true
# client.products().fetch()
# .then (result) ->
#   # result.statusCode
#   # result.body
#   # result.http
#   # result.http.request
#   # result.http.response
# ```
#
# Examples
#
#   {SphereClient} = require 'sphere-node-sdk'
#   client = new SphereClient
#     config:
#       project_key: 'foo'
#       client_id: '123'
#       client_secret: 'secret'
#     user_agent: 'sphere-node-sdk'
#     task: {} # optional TaskQueue instance
#     stats:
#       includeHeaders: true
#   client.products()
#   .where('name(en="Foo")')
#   .where('id="1234567890"')
#   .whereOperator('or')
#   .page(3)
#   .perPage(25)
#   .sort('name', false)
#   .expand('masterData.staged.productType')
#   .expand('masterData.staged.categories[*]')
#   .fetch()
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
    @_serviceOptions =
      _rest: @_rest
      _task: @_task
      _stats: _.defaults options.stats or {},
        includeHeaders: false

    # DEPRECATED: use methods
    @cartDiscounts      = new CartDiscountService @_serviceOptions
    @carts              = new CartService @_serviceOptions
    @categories         = new CategoryService @_serviceOptions
    @channels           = new ChannelService @_serviceOptions
    @comments           = new CommentService @_serviceOptions
    @customObjects      = new CustomObjectService @_serviceOptions
    @customers          = new CustomerService @_serviceOptions
    @customerGroups     = new CustomerGroupService @_serviceOptions
    @discountCodes      = new DiscountCodeService @_serviceOptions
    @inventoryEntries   = new InventoryEntryService @_serviceOptions
    @messages           = new MessageService @_serviceOptions
    @orders             = new OrderService @_serviceOptions
    @products           = new ProductService @_serviceOptions
    @productDiscounts   = new ProductDiscountService @_serviceOptions
    @productProjections = new ProductProjectionService @_serviceOptions
    @productTypes       = new ProductTypeService @_serviceOptions
    @project            = new ProjectService @_serviceOptions
    @reviews            = new ReviewService @_serviceOptions
    @shippingMethods    = new ShippingMethodService @_serviceOptions
    @states             = new StateService @_serviceOptions
    @taxCategories      = new TaxCategoryService @_serviceOptions
    @zones              = new ZoneService @_serviceOptions

  # Public: Get a new instance of a `CartDiscountService`
  #
  # Returns a new {CartDiscountService}
  cartDiscounts: ->      new CartDiscountService @_serviceOptions

  # Public: Get a new instance of a `CartService`
  #
  # Returns a new {CartService}
  carts: ->              new CartService @_serviceOptions

  # Public: Get a new instance of a `CategoryService`
  #
  # Returns a new {CategoryService}
  categories: ->         new CategoryService @_serviceOptions

  # Public: Get a new instance of a `ChannelService`
  #
  # Returns a new {ChannelService}
  channels: ->           new ChannelService @_serviceOptions

  # Public: Get a new instance of a `CommentService`
  #
  # Returns a new {CommentService}
  comments: ->           new CommentService @_serviceOptions

  # Public: Get a new instance of a `CustomObjectService`
  #
  # Returns a new {CustomObjectService}
  customObjects: ->      new CustomObjectService @_serviceOptions

  # Public: Get a new instance of a `CustomerService`
  #
  # Returns a new {CustomerService}
  customers: ->          new CustomerService @_serviceOptions

  # Public: Get a new instance of a `CustomerGroupService`
  #
  # Returns a new {CustomerGroupService}
  customerGroups: ->     new CustomerGroupService @_serviceOptions

  # Public: Get a new instance of a `DiscountCodeService`
  #
  # Returns a new {DiscountCodeService}
  discountCodes: ->      new DiscountCodeService @_serviceOptions

  # Public: Get a new instance of a `InventoryEntryService`
  #
  # Returns a new {InventoryEntryService}
  inventoryEntries: ->   new InventoryEntryService @_serviceOptions

  # Public: Get a new instance of a `MessageService`
  #
  # Returns a new {MessageService}
  messages: ->           new MessageService @_serviceOptions

  # Public: Get a new instance of a `OrderService`
  #
  # Returns a new {OrderService}
  orders: ->             new OrderService @_serviceOptions

  # Public: Get a new instance of a `ProductService`
  #
  # Returns a new {ProductService}
  products: ->           new ProductService @_serviceOptions

  # Public: Get a new instance of a `ProductDiscountService`
  #
  # Returns a new {ProductDiscountService}
  productDiscounts: ->   new ProductDiscountService @_serviceOptions

  # Public: Get a new instance of a `ProductProjectionService`
  #
  # Returns a new {ProductProjectionService}
  productProjections: -> new ProductProjectionService @_serviceOptions

  # Public: Get a new instance of a `ProductTypeService`
  #
  # Returns a new {ProductTypeService}
  productTypes: ->       new ProductTypeService @_serviceOptions

  # Public: Get a new instance of a `ProjectService`
  #
  # Returns a new {ProjectService}
  project: ->            new ProjectService @_serviceOptions

  # Public: Get a new instance of a `ReviewService`
  #
  # Returns a new {ReviewService}
  reviews: ->            new ReviewService @_serviceOptions

  # Public: Get a new instance of a `ShippingMethodService`
  #
  # Returns a new {ShippingMethodService}
  shippingMethods: ->    new ShippingMethodService @_serviceOptions

  # Public: Get a new instance of a `StateService`
  #
  # Returns a new {StateService}
  states: ->             new StateService @_serviceOptions

  # Public: Get a new instance of a `TaxCategoryService`
  #
  # Returns a new {TaxCategoryService}
  taxCategories: ->      new TaxCategoryService @_serviceOptions

  # Public: Get a new instance of a `ZoneService`
  #
  # Returns a new {ZoneService}
  zones: ->              new ZoneService @_serviceOptions

  # Public: Define max parallel request to be sent on each request from the {TaskQueue}
  #
  # maxParallel - A {Number} between 1 and 100 (default is 20)
  setMaxParallel: (maxParallel) -> @_task.setMaxParallel maxParallel

module.exports = SphereClient
