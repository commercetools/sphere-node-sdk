Q = require('q')

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
   * Fetch resource defined by [_currentEndpoint]
   * @return {Promise} A promise, fulfilled with an Object or rejected with a SphereError
  ###
  fetch: ->
    deferred = Q.defer()
    @_rest.GET @_currentEndpoint, (e, r, b)=>
      # TODO: wrap / handle responses generally
      # TODO: returns either the raw body or a parsed JSON
      if e
        deferred.reject e
      else
        if r.statusCode is 404
          # since the API doesn't return an error message for a resource not found
          # we return a custom JSON error message
          deferred.resolve
            statusCode: 404
            message: "Endpoint '#{@_currentEndpoint}' not found."
        else
          deferred.resolve JSON.parse b
    deferred.promise

###*
 * The {@link BaseService} service.
###
module.exports = BaseService
