_ = require('underscore')._
Q = require('q')
Utils = require('../utils')

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
   *
   * @param {Rest} [_rest] An instance of the Rest client (sphere-node-connect)
  ###
  constructor: (@_rest)->
    ###*
     * @private
     * Current path for a API resource endpoint which can be modified by appending ids, queries, etc
     * @type {String}
    ###
    @_currentEndpoint = @constructor.baseResourceEndpoint

  ###*
   * Build the endpoint path by appending the given id
   * @param {String} [id] The resource specific id
   * @return {BaseService} Chained instance of this class
  ###
  byId: (id)->
    @_currentEndpoint = "#{@constructor.baseResourceEndpoint}/#{id}"
    this

  ###*
   * Define a {Predicate} used for quering and filtering a resource.
   * http://commercetools.de/dev/http-api.html#predicates
   * @param {String} [predicate] A {Predicate} string for the `where` query parameter.
   * @return {BaseService} Chained instance of this class
  ###
  where: (predicate)->
    # TODO: use query builder (for specific service) to faciliate build queries
    # e.g.: `QueryBuilder.product.name('Foo', 'en')`
    return this unless predicate
    encodedPredicate = encodeURIComponent(predicate)
    @_query = [] unless @_query
    @_query.push encodedPredicate
    this

  ###*
   * Define the logical operator to combine multiple `where` query parameters.
   * @param {String} [operator] a logical operator (default `and`)
   * @return {BaseService} Chained instance of this class
  ###
  whereOperator: (operator = "and")->
    @_queryOperator = switch operator
      when 'and', 'or' then operator
      else 'and'
    this

  sort: -> # noop

  ###*
   * Define the page number to be requested from the complete query result
   * (used for pagination as `offset`)
   * @param {Int} [_page] a number > 1 (default is 1)
   * @return {BaseService} Chained instance of this class
  ###
  page: (@_page)-> this

  ###*
   * Define the number of results to return from a query
   * (used for pagination as `limit`)
   * A limit of `0` returns all results
   * @param {Int} [_perPage] a number >= 0 (default is 100)
   * @return {BaseService} Chained instance of this class
  ###
  perPage: (@_perPage)-> this

  ###*
   * Build a query string from (pre)defined params
   * (to be overriden for custom params)
   * @return {String} the query string
  ###
  queryString: ->
    Utils.buildQueryString
      where: @_query
      whereOperator: @_queryOperator
      page: @_page
      perPage: @_perPage

  ###*
   * Fetch resource defined by [_currentEndpoint] with query parameters
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  fetch: ->
    deferred = Q.defer()
    queryString = @queryString()
    endpoint = @_currentEndpoint
    endpoint += "?#{queryString}" if queryString
    @_rest.GET endpoint, =>
      # TODO: reset 'private' variables
      @wrapResponse.apply(@, _.union(deferred, arguments))
    deferred.promise

  ###*
   * Save a new resource by sending a payload to the [_currentEndpoint]
   * @param {Object} [body] The payload as JSON object
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  save: (body)->
    throw new Error 'Body payload is required for creating a resource' unless body
    deferred = Q.defer()
    payload = JSON.stringify body
    endpoint = @_currentEndpoint
    @_rest.POST endpoint, payload, =>
      @wrapResponse.apply(@, _.union(deferred, arguments))
    deferred.promise

  wrapResponse: (deferred, error, response, body)->
    # TODO: returns either the raw body or a parsed JSON
    if error
      deferred.reject error
    else
      if response.statusCode is 404
        # since the API doesn't return an error message for a resource not found
        # we return a custom JSON error message

        # TODO: get endpoint from response object
        endpoint = response.request.uri.path
        deferred.resolve
          statusCode: 404
          message: "Endpoint '#{endpoint}' not found."
      else
        deferred.resolve JSON.parse body


###*
 * The {@link BaseService} service.
###
module.exports = BaseService
