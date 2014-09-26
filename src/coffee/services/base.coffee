debug = require('debug')('sphere-client')
_ = require 'underscore'
Promise = require 'bluebird'
Utils = require '../utils'

###*
 * @const
 * RegExp to parse time period for last function.
###
REGEX_LAST = /^(\d+)([s|m|h|d|w])$/

###*
 * Creates a new BaseService, containing base functionalities. It should be extended when defining a Service.
 * @class BaseService
###
class BaseService

  ###*
   * @const
   * @private
   * Base path for a API resource endpoint (to be overriden by specific service)
   * @type {String}
  ###
  @baseResourceEndpoint: ''

  ###*
   * Initialize the class.
   * @constructor
   * @param {Object} opts An object containing configuration option and/or instances of {Rest}, {TaskQueue}
  ###
  constructor: (opts = {}) ->
    {@_rest, @_task, @_stats} = opts
    @_setDefaults()

  ###*
   * @private
   * Reset default _currentEndpoint and _params used to build request endpoints
  ###
  _setDefaults: ->
    ###*
     * @private
     * Current path for a API resource endpoint which can be modified by appending ids, queries, etc
     * @type {String}
    ###
    @_currentEndpoint = @constructor.baseResourceEndpoint
    ###*
     * @private
     * Container that holds request parameters such `id`, `query`, etc
     * @type {Object}
    ###
    @_params =
      query:
        where: []
        operator: 'and'
        sort: []
        expand: []

  ###*
   * Build the endpoint path by appending the given id
   * @param {String} id The resource specific id
   * @return {BaseService} Chained instance of this class
  ###
  byId: (id) ->
    @_currentEndpoint = "#{@constructor.baseResourceEndpoint}/#{id}"
    @_params.id = id
    debug 'setting endpoint id: %j', @_currentEndpoint
    this

  ###*
   * Define a {Predicate} used for quering and filtering a resource.
   * @link http://commercetools.de/dev/http-api.html#predicates
   * @param {String} [predicate] A {Predicate} string for the `where` query parameter.
   * @return {BaseService} Chained instance of this class
  ###
  where: (predicate) ->
    # TODO: use query builder (for specific service) to faciliate build queries
    # e.g.: `QueryBuilder.product.name('Foo', 'en')`
    return this unless predicate
    encodedPredicate = encodeURIComponent(predicate)
    @_params.query.where.push encodedPredicate
    debug 'setting predicate: %s', predicate
    this

  ###*
   * Define the logical operator to combine multiple `where` query parameters.
   * @param {String} [operator] A logical operator (default `and`)
   * @return {BaseService} Chained instance of this class
  ###
  whereOperator: (operator = 'and') ->
    @_params.query.operator = switch operator
      when 'and', 'or' then operator
      else 'and'
    debug 'setting where operator: %s', operator
    this

  ###*
   * This is a convenient method to query for the latest changes.
   * @param {String} period time period of format "numberX" where "X" is one of the follwing units:
   * s -> seconds
   * m -> minutes
   * h -> hours
   * d -> days
   * w -> weeks
   * @throws {Error} If period cannot be parsed
   * @return {BaseService} Chained instance of this class
  ###
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

  ###*
   * Define how the query should be sorted.
   * It is possible to add several sort criteria, thereby the order is relevant.
   * @param {String} path Sort path to search for
   * @param {Boolean} [ascending] Whether the direction should be ascending or not, (default `asc`)
   *                              `true` = asc, `false` = desc
   * @return {BaseService} Chained instance of this class
  ###
  sort: (path, ascending = true) ->
    direction = if ascending then 'asc' else 'desc'
    @_params.query.sort.push encodeURIComponent("#{path} #{direction}")
    debug 'setting sort: %s %s', path, direction
    this

  ###*
   * Define the page number to be requested from the complete query result
   * (used for pagination as `offset`)
   * @param {Number} page A number >= 1 (default is 1)
   * @throws {Error} If argument is not a number >= 1
   * @return {BaseService} Chained instance of this class
  ###
  page: (page) ->
    throw new Error 'Page must be a number >= 1' if _.isNumber(page) and page < 1
    @_params.query.page = page
    debug 'setting page: %s', page
    this

  ###*
   * Define the number of results to return from a query
   * (used for pagination as `limit`)
   * @see _pagedFetch if limit is `0` (all results)
   * @param {Number} perPage A number >= 0 (default is 100)
   * @throws {Error} If argument is not a number >= 0
   * @return {BaseService} Chained instance of this class
  ###
  perPage: (perPage) ->
    throw new Error 'PerPage (limit) must be a number >= 0' if _.isNumber(perPage) and perPage < 0
    @_params.query.perPage = perPage
    debug 'setting perPage: %s', perPage
    this

  ###*
   * Alias for {@link perPage(0)}.
  ###
  all: -> @perPage(0)

  ###*
   * Define an {ExpansionPath} used for expanding {Reference}s of a resource.
   * @link http://commercetools.de/dev/http-api.html#reference-expansion
   * @param {String} [expansionPath] An {ExpansionPath} string for the `expand` query parameter.
   * @return {BaseService} Chained instance of this class
  ###
  expand: (expansionPath) ->
    return this unless expansionPath
    encodedExpansionPath = encodeURIComponent(expansionPath)
    @_params.query.expand.push encodedExpansionPath
    debug 'setting expand: %s', expansionPath
    this

  ###*
   * @private
   * Build a query string from (pre)defined params
   * (to be overriden for custom params)
   * @return {String} the query string
  ###
  _queryString: ->
    qs = Utils.buildQueryString
      where: @_params.query.where
      whereOperator: @_params.query.operator
      page: @_params.query.page
      perPage: @_params.query.perPage
      sort: @_params.query.sort
      expand: @_params.query.expand
    debug 'query string: %s', qs
    qs

  ###*
   * Fetch resource defined by _currentEndpoint with query parameters
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  fetch: ->
    _getEndpoint = =>
      queryString = @_queryString()
      endpoint = @_currentEndpoint
      endpoint += "?#{queryString}" if queryString
      endpoint

    if @_params.query.perPage is 0
      # we should provide a default sorting when fetching all results
      @sort 'id' if _.isEmpty @_params.query.sort
      @_paged(_getEndpoint())
    else
      @_get(_getEndpoint())

  ###*
   * Process the resources for each page separatly using the function fn.
   * The function fn will then be called once for per page.
   * The function fn has to return a promise that should be resolved when all elements of the page are processed.
   * @param {Function} fn The function to process a page that returns a promise
   * @throws {Error} If argument is not a function
   * @return {Promise} A promise, fulfilled with an array of the resolved results of function fn or the rejected result of fn
   * @example
   *   page(3).perPage(5) will start processing at element 10, gives you a payload of 5 elements per call of fn again and again until all elements are processed.
  ###
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

  ###*
   * Save a new resource by sending a payload to the _currentEndpoint, describing
   * the new resource model.
   * If the `id` was provided, the API expects the request to be an update by
   * by providing a payload of {UpdateAction}.
   * @param {Object} body The payload as JSON object
   * @throws {Error} If body is not given
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  save: (body) ->
    unless body
      throw new Error "Body payload is required for creating a resource (endpoint: #{@constructor.baseResourceEndpoint})"

    endpoint = @constructor.baseResourceEndpoint
    @_save(endpoint, body)

  ###*
   * Alias for {@link save}.
  ###
  create: -> @save.apply(@, arguments)

  ###*
   * Alias for {@link save}, as it's the same type of HTTP request.
   * Updating a resource is done by sending a list of {UpdateAction}.
   * (more intuitive way of describing an update, given that an [id] is provided)
   * @example `{service}.byId({id}).update({actions})`
  ###
  update: (body) ->
    throw new Error "Missing resource id. You can set it by chaining '.byId(ID)'" unless @_params.id
    unless body
      throw new Error "Body payload is required for creating a resource (endpoint: #{@_currentEndpoint})"

    endpoint = @_currentEndpoint
    @_save(endpoint, body)

  ###*
   * Delete an existing resource of the _currentEndpoint
   * If the `id` was provided, the API expects this to be a resource update with given {UpdateAction}
   * @param {Number} version The current version of the resource
   * @throws {Error} If version is not given
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  delete: (version) ->
    # TODO: automatically fetch the resource if no version is given?
    # TODO: describe which endpoints support this?
    unless version
      throw new Error "Version is required for deleting a resource (endpoint: #{@_currentEndpoint})"

    endpoint = "#{@_currentEndpoint}?version=#{version}"
    @_delete(endpoint)

  ###*
   * Return a {Promise} for a GET call. It can be overridden for custom logic.
   * @param {String} endpoint The resource endpoint
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  _get: (endpoint) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
      new Promise (resolve, reject) =>
        @_rest.GET endpoint, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  ###*
   * Return a {Promise} for a PAGED call. It can be overridden for custom logic.
   * @param {String} endpoint The resource endpoint
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  _paged: (endpoint) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
      new Promise (resolve, reject) =>
        # fetch all results in chunks
        @_rest.PAGED endpoint, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  ###*
   * Return a {Promise} for a POST call. It can be overridden for custom logic.
   * @param {String} endpoint The resource endpoint
   * @param {String} payload The body payload as a String
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  _save: (endpoint, payload) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
        payload: payload
      new Promise (resolve, reject) =>
        @_rest.POST endpoint, payload, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  ###*
   * Return a {Promise} for a DELETE call. It can be overridden for custom logic.
   * @param {String} endpoint The resource endpoint
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  _delete: (endpoint) ->
    @_setDefaults()
    @_task.addTask =>
      originalRequest =
        endpoint: endpoint
      new Promise (resolve, reject) =>
        @_rest.DELETE endpoint, =>
          @_wrapResponse.apply(@, [resolve, reject, originalRequest].concat(_.toArray(arguments)))

  ###*
   * @private
   * Wrap responses and decide whether to reject or resolve the promise
   * @param {Function} resolve The function called to resolve the promise
   * @param {Function} reject The function called to reject the promise
   * @param {Object} error An error object when applicable (usually from `http.ClientRequest` object) otherwise `null`
   * @param {Object} response An `http.IncomingMessage` object containing all kind of information about the request / response
   * @param {Object} body A JSON object containing the HTTP API resource or error messages
  ###
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
      errorResp =
        statusCode: 500
        message: error
        originalRequest: originalRequest
      errorResp.body = body if body
      reject _.extend(responseJson, errorResp)
    else
      # TODO: check other possible acceptable codes (304, ...)
      if 200 <= response.statusCode < 300
        resolve _.extend responseJson,
          statusCode: response.statusCode
          body: body
      else if response.statusCode is 404
        endpoint = response.request.uri.path
        # since the API doesn't return an error message for a resource not found
        # we return a custom JSON error message
        reject _.extend responseJson,
          statusCode: 404
          message: "Endpoint '#{endpoint}' not found."
          originalRequest: originalRequest
      else
        # a ShereError response e.g.: {statusCode: 400, message: 'Oops, something went wrong'}
        reject _.extend responseJson, body, {originalRequest: originalRequest}


###*
 * The {@link BaseService} service.
###
module.exports = BaseService
