_                        = require 'underscore'
Rest                     = require './connect/rest'
TaskQueue                = require './task-queue'
RepeaterTaskQueue        = require '../lib/repeater-task-queue'
CartDiscountService      = require './services/cart-discounts'
CartService              = require './services/carts'
CategoryService          = require './services/categories'
ChannelService           = require './services/channels'
CustomObjectService      = require './services/custom-objects'
CustomerService          = require './services/customers'
CustomerGroupService     = require './services/customer-groups'
DiscountCodeService      = require './services/discount-codes'
GraphQLService           = require './services/graphql'
InventoryEntryService    = require './services/inventory-entries'
MessageService           = require './services/messages'
OrderService             = require './services/orders'
PaymentService           = require './services/payments'
ProductDiscountService   = require './services/product-discounts'
ProductService           = require './services/products'
ProductProjectionService = require './services/product-projections'
ProductTypeService       = require './services/product-types'
ProjectService           = require './services/project'
ReviewService            = require './services/reviews'
ShippingMethodService    = require './services/shipping-methods'
StateService             = require './services/states'
TaxCategoryService       = require './services/tax-categories'
TypeService              = require './services/types'
ZoneService              = require './services/zones'

ALL_SERVICES = [
  {key: 'cartDiscounts',      name: CartDiscountService},
  {key: 'carts',              name: CartService},
  {key: 'categories',         name: CategoryService},
  {key: 'channels',           name: ChannelService},
  {key: 'customObjects',      name: CustomObjectService},
  {key: 'customers',          name: CustomerService},
  {key: 'customerGroups',     name: CustomerGroupService},
  {key: 'discountCodes',      name: DiscountCodeService},
  {key: 'graphql',            name: GraphQLService},
  {key: 'inventoryEntries',   name: InventoryEntryService},
  {key: 'messages',           name: MessageService},
  {key: 'orders',             name: OrderService},
  {key: 'payments',           name: PaymentService},
  {key: 'products',           name: ProductService},
  {key: 'productDiscounts',   name: ProductDiscountService},
  {key: 'productProjections', name: ProductProjectionService},
  {key: 'productTypes',       name: ProductTypeService},
  {key: 'project',            name: ProjectService},
  {key: 'reviews',            name: ReviewService},
  {key: 'shippingMethods',    name: ShippingMethodService},
  {key: 'states',             name: StateService},
  {key: 'taxCategories',      name: TaxCategoryService},
  {key: 'types',              name: TypeService}
  {key: 'zones',              name: ZoneService}
]

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
# Optionally some [statistics](#statistics) are also passed along.
#
# ### TaskQueue
# To optimize processing lots of requests all together, e.g.: avoiding connection timeouts, we introduced {TaskQueue}.
# Every request is internally pushed in a queue which automatically starts resolving promises (requests)
# and will process concurrently some of them based on the `maxParallel` parameter. You can set this parameter by calling {::setMaxParallel}.
#
# ### RepeaterTaskQueue
# To repeat request on case of some errors. It's possible to use custom repeater by passing it to constructor.
# Also it's possible to turn off by passing `enableRepeater = false` flag.
# There is a default repeater if constructor parameter is empty.
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
# An {Error} instance contains a `body`, which is a JSON object containing the following response information:
# - `statusCode`
# - `originalRequest` - useful information from the failed request
# - `http` - optional object containing header information (see [statistics](#statistics))
#
# ```coffeescript
# Errors = require('sphere-node-sdk').Errors
# client.products.byId(productId).update(payload)
# .then (result) ->
#   # we know the request was successful (e.g.: 2xx) and `result` is a JSON of a resource representation
# .catch (e) ->
#   # something went wrong, either an unexpected error or a HTTP API error response
#   # here we can check the error type to differentiate the error
#   if e instanceof Errors.SphereHttpError.ConcurrentModification
#     # e.statusCode => 409
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
# - `maskSensitiveHeaderData` If set to true, it will filter out all sensitive data like authorisation from response headers. By default it is set to false.
#
# Each response from the HTTP API contains a header `x-correlation-id`.
# This unique value can be used to correlate events across different layers and also might help in case of failures.
# Note: the SDK doesn't have any logic about that, thus it's up to applications to decide whether to log this header or not.
#
# ```coffeescript
# client = new SphereClient
#   config: # credentials
#   stats:
#     includeHeaders: true
#     maskSensitiveHeaderData: false
# client.products.fetch()
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
#       maskSensitiveHeaderData: false
#   client.products
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
  # When the client is instantiated it has all available instances of services
  # as a property, which can be directly accessed (Note: _this may change in future releases_).
  #
  # ```coffeescript
  # client = new SphereClient
  # # examples
  # productService = client.products
  # cartService = client.carts
  # ```
  #
  # Available services are
  # - `cartDiscounts`
  # - `carts`
  # - `categories`
  # - `channels`
  # - `customObjects`
  # - `customers`
  # - `customerGroups`
  # - `discountCodes`
  # - `graphql`
  # - `inventoryEntries`
  # - `messages`
  # - `orders`
  # - `payments`
  # - `products`
  # - `productDiscounts`
  # - `productProjections`
  # - `productTypes`
  # - `project`
  # - `reviews`
  # - `shippingMethods`
  # - `states`
  # - `taxCategories`
  # - `types`
  # - `zones`
  #
  # options - An {Object} to configure the client
  constructor: (options = {}) ->
    # Private: instance of a {TaskQueue}
    if options.enableRepeater? and !options.enableRepeater
      @_task = new TaskQueue
    else
      @_task = options.task or new RepeaterTaskQueue {}, {}

    # Private: instance of a {Rest}
    @_rest = options.rest or new Rest _.defaults options, {user_agent: 'sphere-node-sdk'}

    # Private: wrapper to pass different options to new service instances
    _serviceOptions =
      _rest: @_rest
      _task: @_task
      _stats: _.defaults options.stats or {},
        includeHeaders: false
        maskSensitiveHeaderData: false

    # TODO: currently instances are bound to the client as properties (e.g.: client.products)
    # We may think to provide a better interface for that, so for now we keep it like this
    # but this may change (breaking change).
    ALL_SERVICES.forEach (service) =>
      this[service.key] = new service.name _serviceOptions

  # Public: Define max parallel request to be sent on each request from the {TaskQueue}
  #
  # maxParallel - A {Number} between 1 and 100 (default is 20)
  setMaxParallel: (maxParallel) -> @_task.setMaxParallel maxParallel

module.exports = SphereClient
