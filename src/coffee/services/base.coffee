debug = require('debug')('sphere-client')
_ = require 'underscore'
_.mixin require('underscore-mixins')
Promise = require 'bluebird'
Utils = require '../utils'
{HttpError, SphereHttpError} = require '../errors'

# Private: RegExp to parse time period for last function.
REGEX_LAST = /^(\d+)([s|m|h|d|w])$/

# Abstract: Define a `BaseService` to provide basic methods to interact with the HTTP API.
#
# This class should **not be exposed** and **must be extended** when defining a new `*Service`.
#
# Examples
#
#   class FooService extends BaseService
#     @baseResourceEndpoint: '/foo'
class BaseService

  # Internal: Base path for a API resource endpoint (to be overriden by specific service) ({String})
  # constant
  @baseResourceEndpoint: ''

  # Public: Construct a `*Service` object.
  #
  # options - An {Object} to configure the service
  #           :_rest - a {Rest} instance
  #           :_task - a {TaskQueue} instance
  #           :_stats - an {Object} to configure statistics
  constructor: (options = {}) ->
    {@_rest, @_task, @_stats} = options
    @_setDefaults()

  # Private: Reset default _currentEndpoint and _params used to build request endpoints
  _setDefaults: ->
    # Private: Current path for a API resource endpoint which can be modified by appending ids, queries, etc
    @_currentEndpoint = @constructor.baseResourceEndpoint

    # Private: Container that holds request parameters such `id`, `query`, etc
    @_params =
      encoded: ['where', 'expand', 'sort']
      query:
        where: []
        operator: 'and'
        sort: []
        expand: []

  # Public: Build the endpoint path by appending the given id
  #
  # id - {String} The resource specific id
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.byId('123').fetch()
  byId: (id) ->
    @_currentEndpoint = "#{@constructor.baseResourceEndpoint}/#{id}"
    @_params.id = id
    debug 'setting endpoint id: %j', @_currentEndpoint
    this

  # Public: Define a URI encoded [Predicate](http://dev.sphere.io/http-api.html#predicates)
  # from the given string, used for quering and filtering a resource. Can be set multiple times.
  #
  # predicate - {String} A [Predicate](http://dev.sphere.io/http-api.html#predicates) string for the `where` query parameter.
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.where('name(en = "Foo")').fetch()
  where: (predicate) ->
    # TODO: use query builder (for specific service) to faciliate build queries
    # e.g.: `QueryBuilder.product.name('Foo', 'en')`
    return this unless predicate
    encodedPredicate = encodeURIComponent(predicate)
    @_params.query.where.push encodedPredicate
    debug 'setting predicate: %s', predicate
    this

  # Public: Define the logical operator to combine multiple {::where} query parameters.
  #
  # operator - {String} A logical operator (default `and`)
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.whereOperator('or')
  #   .where('name(en = "Red")')
  #   .where('name(de = "Rot")')
  #   .fetch()
  whereOperator: (operator = 'and') ->
    @_params.query.operator = switch operator
      when 'and', 'or' then operator
      else 'and'
    debug 'setting where operator: %s', operator
    this

  # Public: This is a convenient method to query for the latest changes.
  #
  # Please be aware that `last` is just another `where` clause and thus
  # depends on the `operator` you choose.
  #
  # predicate - {String} Time period of format `numberX` where `X` is one of the follwing units:
  #           :s - seconds
  #           :m - minutes
  #           :h - hours
  #           :d - days
  #           :w - weeks
  #
  # Throws an {Error} if `period` cannot be parsed
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.last('10d').fetch()
  last: (period) ->
    throw new Error "Cannot parse period '#{period}'" unless REGEX_LAST.test(period)

    matches = REGEX_LAST.exec(period)
    amount = matches[1]

    if amount is '0'
      return this

    before = Utils.getTime amount, matches[2]
    now = new Date().getTime()
    dateTime = new Date(now - before).toISOString()
    @where("lastModifiedAt > \"#{dateTime}\"")

  # Public: Define how the query should be sorted.
  # It is possible to add several sort criteria, thereby the order is relevant.
  #
  # path - {String} Sort path to search for
  # ascending - {Boolean} Whether the direction should be ascending or not, (default `asc`)
  #   :true - `asc`
  #   :false - `desc`
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.sort('name.en', true).fetch()
  sort: (path, ascending = true) ->
    direction = if ascending then 'asc' else 'desc'
    @_params.query.sort.push encodeURIComponent("#{path} #{direction}")
    debug 'setting sort: %s %s', path, direction
    this

  # Public: Define the page number to be requested from the complete query result (used for pagination as `offset`)
  #
  # page - {Number} The page number `>= 1` (default is 1)
  #
  # Throws an {Error} if `page` is not a positive number
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.page(4).fetch()
  page: (page) ->
    throw new Error 'Page must be a number >= 1' if _.isNumber(page) and page < 1
    @_params.query.page = page
    debug 'setting page: %s', page
    this

  # Public: Define the number of results to return from a query (used for pagination as `limit`)
  #
  # perPage - {Number} How many results in a page, it must be `>= 0` (default is 100)
  #
  # Throws an {Error} if `perPage` is not a positive number
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.perPage(50).fetch()
  perPage: (perPage) ->
    throw new Error 'PerPage (limit) must be a number >= 0' if _.isNumber(perPage) and perPage < 0
    @_params.query.perPage = perPage
    debug 'setting perPage: %s', perPage
    this

  # Public: A convenient method to set {::perPage} to `0`, which will fetch all pages
  # recursively in chunks and return them all together once completed.
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.all().fetch()
  all: -> @perPage(0)

  # Public: Define an [ExpansionPath](http://dev.sphere.io/http-api.html#reference-expansion)
  # used for expanding [Reference](http://dev.sphere.io/http-api-types.html#reference)s of a resource.
  #
  # expansionPath - {String} An [ExpansionPath](http://dev.sphere.io/http-api.html#reference-expansion) for the `expand` query parameter
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.expand('productType').fetch()
  expand: (expansionPath) ->
    return this unless expansionPath
    encodedExpansionPath = encodeURIComponent(expansionPath)
    @_params.query.expand.push encodedExpansionPath
    debug 'setting expand: %s', expansionPath
    this

  # Public: Allow to pass a literal query string
  #
  # query - {String} The literal query string
  # withEncodedParams - {Boolean} Whether the given query string has encoded params or not (default false)
  #
  # Returns a chained instance of `this` class
  #
  # Examples
  #
  #   service = client.products
  #   service.byQueryString('where=slug(en = "my-slug")&limit=5&staged=true', false)
  #   .fetch()
  byQueryString: (query, withEncodedParams = false) ->
    parsed = _.parseQuery(query, false)
    unless withEncodedParams
      # when we rebuild the query string, we need to encode following parameters
      _.each @_params.encoded, (param) ->
        if parsed[param]
          parsed[param] = _.map _.flatten([parsed[param]]), (p) -> encodeURIComponent(p)
    @_params.queryString = _.stringifyQuery(parsed)
    debug 'setting queryString: %s', query
    this

  # Private: Build a query string from (pre)defined params (can be overriden for custom params)
  #
  # Returns the built query string
  _queryString: ->
    qs = if @_params.queryString
      @_params.queryString
    else
      Utils.buildQueryString
        where: @_params.query.where
        whereOperator: @_params.query.operator
        page: @_params.query.page
        perPage: @_params.query.perPage
        sort: @_params.query.sort
        expand: @_params.query.expand
    debug 'built query string: %s', qs
    qs

  # Public: Fetch resource defined by the `Service` with all chained query parameters.
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of {HttpError} or {SphereError}
  #
  # Examples
  #
  #   service = client.products
  #   service.where('name(en = "Foo")').sort('createdAt desc').fetch()
  #
  #   client.products.fetch()
  fetch: ->
    _getEndpoint = =>
      queryString = @_queryString()
      endpoint = @_currentEndpoint
      endpoint += "?#{queryString}" if queryString
      endpoint

    if not @_params.queryString and @_params.query.perPage is 0
      # we should provide a default sorting when fetching all results
      @sort 'id' if _.isEmpty @_params.query.sort
      @_paged(_getEndpoint())
    else
      @_get(_getEndpoint())

  # Public: Process the resources for each `page` separately using the function `fn`.
  # The function `fn` will then be called once per page and has to return a
  # {Promise} that should be resolved when all elements of the page are processed.
  #
  # Batch processing allows to process a lot of resources in chunks.
  # Using this approach you can balance between memory usage and parallelism.
  #
  # fn - {Function} The function called for each processing page (it must return a {Promise})
  # options - {Object} To configure the processing
  #         :accumulate - {Boolean} Whether the results should be accumulated or not (default true)
  #
  # Throws an {Error} if `fn` is not a {Function}
  #
  # Returns a {Promise}, fulfilled with an {Array} of the results of each resolved
  # page from the `fn`, or rejected with an instance of an {HttpError} or {SphereError}
  #
  # Examples
  #
  #   # Define your custom function, which returns a promise
  #   fn = (payload) ->
  #     new Promise (resolve, reject) ->
  #       # do something with the payload
  #       if # something unexpected happens
  #         reject 'BAD'
  #       else # good case
  #         resolve 'OK'
  #   service = client.products
  #   service.perPage(20).process(fn)
  #   .then (result) ->
  #     # here we get the total result, which is just an array of all pages accumulated
  #     # eg: ['OK', 'OK', 'OK'] if you have 41 to 60 products - the function fn is called three times
  #   .catch (error) ->
  #     # eg: 'BAD'
  process: (fn, options = {}) ->
    throw new Error 'Please provide a function to process the elements' unless _.isFunction fn

    new Promise (resolve, reject) =>

      options = _.defaults options,
        accumulate: true # whether the results should be accumulated or not

      endpoint = @constructor.baseResourceEndpoint
      originalQuery = @_params.query

      _processPage = (page, perPage, total, acc = []) =>
        debug 'processing next page with params: %j',
          page: page
          perPage: perPage,
          offset: (page - 1) * perPage
          total: total
        if total? and (page - 1) * perPage >= total
          resolve acc
        else
          @_params.query = _.extend {}, originalQuery,
            page: page
            perPage: perPage
          @sort 'id' if _.isEmpty @_params.query.sort
          queryString = @_queryString()

          @_get("#{endpoint}?#{queryString}")
          .then (payload) ->
            fn(payload)
            .then (result) ->
              newTotal = payload.body.total
              if not total or total is newTotal
                nextPage = page + 1
              else if total < newTotal
                nextPage = page
                debug 'Total is bigger then before, assuming something has been newly created. Processing the same page (%s).', nextPage
              else
                nextPage = page - 1
                nextPage = 1 if nextPage < 1
                debug 'Total is lesser then before, assuming something has been deleted. Reducing page to %s (min 1).', nextPage
              accumulated = acc.concat(result) if options.accumulate
              _processPage nextPage, perPage, newTotal, accumulated
          .catch (error) -> reject error
          .done()
      _processPage(@_params.query.page or 1, @_params.query.perPage or 20)

  # Public: Save a new resource defined by the `Service` by passing the payload {Object}.
  #
  # body - {Object} The payload described by the related API resource as JSON
  #
  # Throws an {Error} if `body` is missing
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  #
  # Examples
  #
  #   service = client.products
  #   service.save
  #     name:
  #       en: 'Foo'
  #     slug:
  #       en: 'foo'
  #     productType:
  #       id: '123'
  #       typeId: 'product-type'
  save: (body) ->
    unless body
      throw new Error "Body payload is required for creating a resource (endpoint: #{@constructor.baseResourceEndpoint})"

    endpoint = @constructor.baseResourceEndpoint
    @_save(endpoint, body)

  # Public: Alias of {::save}
  create: -> @save.apply(@, arguments)

  # Public: Update a resource defined by the `Service` by passing the payload {Object}
  # with [UpdateAction](http://dev.sphere.io/http-api.html#partial-updates).
  # The `id` of the resource must be provided with {::byId}.
  #
  # body - {Object} The payload described by the related API resource as JSON
  #
  # Throws an {Error} if resource `id` is missing
  # Throws an {Error} if `body` is missing
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  #
  # Examples
  #
  #   service = client.products
  #   service.byId('123').update
  #     version: 2
  #     actions: [
  #       {
  #         action: 'changeName'
  #         name:
  #           en: Bar
  #       }
  #     ]
  update: (body) ->
    throw new Error "Missing resource id. You can set it by chaining '.byId(ID)'" unless @_params.id
    unless body
      throw new Error "Body payload is required for updating a resource (endpoint: #{@_currentEndpoint})"

    endpoint = @_currentEndpoint
    @_save(endpoint, body)

  # Public: Delete an existing resource defined by the `Service`
  #
  # version - {Number} The current version of the resource to delete
  #
  # Throws an {Error} if `version` is missing
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  #
  # Examples
  #
  #   service = client.products
  #   service.byId('123').delete(2)
  delete: (version) ->
    # TODO: automatically fetch the resource if no version is given?
    # TODO: describe which endpoints support this?
    unless version
      throw new Error "Version is required for deleting a resource (endpoint: #{@_currentEndpoint})"

    endpoint = "#{@_currentEndpoint}?version=#{version}"
    @_delete(endpoint)

  # Private: Return a {Promise} for a GET call. It can be overridden for custom logic.
  #
  # endpoint - {String} The resource endpoint
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  _get: (endpoint) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
      new Promise (resolve, reject) =>
        @_rest.GET endpoint, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  # Private: Return a {Promise} for a PAGED call. It can be overridden for custom logic.
  #
  # endpoint - {String} The resource endpoint
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  _paged: (endpoint) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
      new Promise (resolve, reject) =>
        # fetch all results in chunks
        @_rest.PAGED endpoint, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  # Private: Return a {Promise} for a POST call. It can be overridden for custom logic.
  #
  # endpoint - {String} The resource endpoint
  # payload - {Object} The body payload as JSON
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  _save: (endpoint, payload) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
        payload: payload
      new Promise (resolve, reject) =>
        @_rest.POST endpoint, payload, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  # Private: Return a {Promise} for a DELETE call. It can be overridden for custom logic.
  #
  # endpoint - {String} The resource endpoint
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {HttpError} or {SphereError}
  _delete: (endpoint) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
      new Promise (resolve, reject) =>
        @_rest.DELETE endpoint, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  # Private: Wrap the HTTP response and decide whether to reject or resolve the promise
  #
  # resolve - {Function} The function called to `resolve` the {Promise}
  # reject - {Function} The function called to `reject` the {Promise}
  # originalRequest - {Object} The object containing information about the request, used when the request fails
  # error - {Object} An error object when applicable (usually from `http.ClientRequest` object) otherwise `null`
  # response - {Object} An `http.IncomingMessage` object containing all kind of information about the request / response
  # body - {Object} A JSON object containing the HTTP API resource or error messages
  _wrapResponse: (resolve, reject, originalRequest, error, response, body) ->
    responseJson =
      if @_stats.includeHeaders
        http:
          request:
            method: response.request.method
            httpVersion: response.httpVersion
            uri: response.request.uri
            header: response.req._header
            headers: response.request.headers
          response:
            headers: response.headers
      else {}

    if error
      if error instanceof Error
        errorMessage = error.message
      else
        errorMessage = error
      errorResp =
        statusCode: response?.statusCode or 500
        message: errorMessage
        originalRequest: originalRequest
      errorResp.body = body if body
      errorBody = _.extend(responseJson, errorResp)
      reject new HttpError errorMessage, errorBody
    else
      # check for API deprecation headers
      if response.headers?['X-DEPRECATION-NOTICE']
        console.warn("Deprecation notice: #{response.headers['X-DEPRECATION-NOTICE']}")

      # TODO: check other possible acceptable codes (304, ...)
      if 200 <= response.statusCode < 300
        resolve _.extend responseJson,
          statusCode: response.statusCode
          body: body
      else if response.statusCode is 404
        endpoint = response.request.uri.path
        # since the API doesn't return an error message for a resource not found
        # we return a custom JSON error message
        reject new SphereHttpError.NotFound "Endpoint '#{endpoint}' not found.",
          _.extend responseJson,
            statusCode: 404
            message: "Endpoint '#{endpoint}' not found."
            originalRequest: originalRequest
      else
        # a ShereError response e.g.: {statusCode: 400, message: 'Oops, something went wrong'}
        errorMessage = body.message or 'Undefined SPHERE.IO error message'
        errorBody = _.extend responseJson, body,
          statusCode: body.statusCode or response.statusCode
          originalRequest: originalRequest
        # TODO: automatically retry code 503, 504
        reject switch body.statusCode
          when 400 then new SphereHttpError.BadRequest errorMessage, errorBody
          when 409 then new SphereHttpError.ConcurrentModification errorMessage, errorBody
          when 500 then new SphereHttpError.InternalServerError errorMessage, errorBody
          when 503 then new SphereHttpError.ServiceUnavailable errorMessage, errorBody
          else new HttpError require('http').STATUS_CODES[response.statusCode], _.extend responseJson,
            statusCode: response.statusCode
            originalRequest: originalRequest

module.exports = BaseService
