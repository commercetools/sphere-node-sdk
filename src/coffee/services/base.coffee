_ = require 'underscore'
Q = require 'q'
Utils = require '../utils'

###*
 * @const
 * RegExp to parse time period for last function.
###
REGEX_LAST = /^(\d+)([s|m|h|d])$/

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
   * @param {Rest} _rest An instance of the Rest client (sphere-node-connect)
   * @param {Logger} _logger An instance of a Logger (https://github.com/emmenko/sphere-node-connect#logging)
  ###
  constructor: (@_rest, @_logger, @_task) -> @_setDefaults()

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
      maxParallel: 20
      query:
        where: []
        operator: 'and'
        sort: []

  ###*
   * Build the endpoint path by appending the given id
   * @param {String} id The resource specific id
   * @return {BaseService} Chained instance of this class
  ###
  byId: (id) ->
    @_currentEndpoint = "#{@constructor.baseResourceEndpoint}/#{id}"
    @_params.id = id
    @_logger.debug @_currentEndpoint, 'Setting endpoint with ID'
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
    @_logger.debug @_params.query, 'Setting \'where\' parameters'
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
    @_logger.debug @_params.query, 'Setting \'where\' operator'
    this

  ###*
   * This is a convenient method to query for the latest changes.
   * @param {String} period time period of format "numberX" where "X" is one of the follwing units:
   * s -> seconds
   * m -> minutes
   * h -> hours
   * d -> days
   * @return {BaseService} Chained instance of this class
  ###
  last: (period) ->
    throw new Error "Cannot parse period '#{period}'" unless REGEX_LAST.test(period)

    matches = REGEX_LAST.exec(period)
    amount = matches[1]

    if amount is '0'
      return this

    kind = matches[2]
    millis = switch kind
      when 's' then amount * 1000
      when 'm' then amount * 1000 * 60
      when 'h' then amount * 1000 * 60 * 60
      when 'd' then amount * 1000 * 60 * 60 * 24
      else 0

    now = new Date().getTime()
    queryData = new Date(now - millis).toISOString()
    @where("lastModifiedAt > \"#{queryData}\"")

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
    @_logger.debug @_params.query, 'Setting \'sort\' parameter'
    this

  ###*
   * Define the page number to be requested from the complete query result
   * (used for pagination as `offset`)
   * @param {Number} page A number >= 1 (default is 1)
   * @return {BaseService} Chained instance of this class
  ###
  page: (page) ->
    throw new Error 'Page must be a number >= 1' if _.isNumber(page) and page < 1
    @_params.query.page = page
    @_logger.debug @_params.query, 'Setting \'page\' parameter'
    this

  ###*
   * Define the number of results to return from a query
   * (used for pagination as `limit`)
   * @see _pagedFetch if limit is `0` (all results)
   * @param {Number} perPage A number >= 0 (default is 100)
   * @return {BaseService} Chained instance of this class
  ###
  perPage: (perPage) ->
    throw new Error 'PerPage (limit) must be a number >= 0' if _.isNumber(perPage) and perPage < 0
    @_params.query.perPage = perPage
    @_logger.debug @_params.query, 'Setting \'perPage\' parameter'
    this

  ###*
   * Define max parallel request to be sent on each request from the {TaskQueue}
   * @param {Number} maxParallel A number >= 1 (default is 20)
   * @return {BaseService} Chained instance of this class
  ###
  parallel: (maxParallel) ->
    throw new Error 'MaxParallel must be a number >= 1' if _.isNumber(maxParallel) and maxParallel < 1
    @_params.maxParallel = maxParallel
    @_logger.debug @_params.maxParallel, 'Setting \'maxParallel\' parameter'
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
    @_logger.debug qs, 'Query string generated'
    qs

  ###*
   * Fetch resource defined by _currentEndpoint with query parameters
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  fetch: ->
    queryString = @_queryString()
    endpoint = @_currentEndpoint
    endpoint += "?#{queryString}" if queryString

    if @_params.query.perPage is 0
      @_paged(endpoint)
    else
      @_get(endpoint)

  ###*
   * Process the resources for each page separatly using the function fn.
   * The function fn will then be called once for per page.
   * The function fn has to return a promise that should be resolved when all elements of the page are processed.
   * @param {Function} the function to process a page that returns a promise
   * @return {Promise} A promise, fulfilled with an array of the resolved results of function fn or the rejected result of fn
   * @example
   *   page(3).perPage(5) will start processing at element 10, gives you a payload of 5 elements per call of fn again and again until all elements are processed.
  ###
  process: (fn) ->
    throw new Error 'Please provide a function to process the elements' unless _.isFunction fn

    deferred = Q.defer()
    endpoint = @_currentEndpoint
    originalQuery = @_params.query

    _processPage = (page, perPage, total, acc = []) =>
      @_logger.debug
        page: page
        perPage: perPage,
        offset: (page - 1) * perPage
        total: total
      , 'Processing next page'
      if total? and (page - 1) * perPage >= total
        deferred.resolve acc
      else
        @_params.query = _.extend {}, originalQuery,
          page: page
          perPage: perPage
        queryString = @_queryString()

        @_get("#{endpoint}?#{queryString}")
        .then (payload) ->
          fn(payload)
          .then (result) ->
            _processPage page + 1, perPage, payload.body.total, acc.concat(result)
        .fail (error) ->
          deferred.reject error
        .done()

    _processPage(@_params.query.page or 1, @_params.query.perPage or 20)
    deferred.promise

  ###*
   * Save a new resource by sending a payload to the _currentEndpoint, describing
   * the new resource model.
   * If the `id` was provided, the API expects the request to be an update by
   * by providing a payload of {UpdateAction}.
   * @param {Object} body The payload as JSON object
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  save: (body) ->
    unless body
      throw new Error "Body payload is required for creating a resource (endpoint: #{@_currentEndpoint})"

    payload = JSON.stringify body
    endpoint = @_currentEndpoint
    @_save(endpoint, payload)

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
  update: -> @save.apply(@, arguments)

  ###*
   * Delete an existing resource of the _currentEndpoint
   * If the `id` was provided, the API expects this to be a resource update with given {UpdateAction}
   * @param {Number} version The current version of the resource
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
    @_task._options.maxParallel = @_params.maxParallel
    @_task.addTask =>
      deferred = Q.defer()
      @_rest.GET endpoint, =>
        @_wrapResponse.apply(@, [deferred].concat(_.toArray(arguments)))
      deferred.promise

  ###*
   * Return a {Promise} for a PAGED call. It can be overridden for custom logic.
   * @param {String} endpoint The resource endpoint
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  _paged: (endpoint) ->
    @_task._options.maxParallel = @_params.maxParallel
    @_task.addTask =>
      deferred = Q.defer()
      # fetch all results in chunks
      @_rest.PAGED endpoint, =>
        @_wrapResponse.apply(@, [deferred].concat(_.toArray(arguments)))
      , (progress) -> deferred.notify progress
      deferred.promise

  ###*
   * Return a {Promise} for a POST call. It can be overridden for custom logic.
   * @param {String} endpoint The resource endpoint
   * @param {String} payload The body payload as a String
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  _save: (endpoint, payload) ->
    @_task._options.maxParallel = @_params.maxParallel
    @_task.addTask =>
      deferred = Q.defer()
      id = JSON.parse(payload).id
      @_rest.POST endpoint, payload, =>
        @_wrapResponse.apply(@, [deferred].concat(_.toArray(arguments)))
      deferred.promise

  ###*
   * Return a {Promise} for a DELETE call. It can be overridden for custom logic.
   * @param {String} endpoint The resource endpoint
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  _delete: (endpoint) ->
    @_task._options.maxParallel = @_params.maxParallel
    @_task.addTask =>
      deferred = Q.defer()
      @_rest.DELETE endpoint, =>
        @_wrapResponse.apply(@, [deferred].concat(_.toArray(arguments)))
      deferred.promise

  ###*
   * @private
   * Wrap responses and decide whether to reject or resolve the promise
   * @param {Promise} deferred The deferred promise
   * @param {Object} error An error object when applicable (usually from `http.ClientRequest` object) otherwise `null`
   * @param {Object} response An `http.IncomingMessage` object containing all kind of information about the request / response
   * @param {Object} body A JSON object containing the HTTP API resource or error messages
  ###
  _wrapResponse: (deferred, error, response, body) ->
    @_setDefaults()
    if error
      deferred.reject
        statusCode: 500
        message: error
    else
      # TODO: check other possible acceptable codes (304, ...)
      if 200 <= response.statusCode < 300
        deferred.resolve
          statusCode: response.statusCode
          body: body
      else if response.statusCode is 404
        endpoint = response.request.uri.path
        # since the API doesn't return an error message for a resource not found
        # we return a custom JSON error message
        deferred.reject
          statusCode: 404
          message: "Endpoint '#{endpoint}' not found."
      else
        # a ShereError response e.g.: {statusCode: 400, message: 'Oops, something went wrong'}
        deferred.reject body


###*
 * The {@link BaseService} service.
###
module.exports = BaseService
