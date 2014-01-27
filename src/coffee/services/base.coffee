Q = require('q')

###*
 * Creates a new BaseService, containing base functionalities. It should be extended when defining a Service.
 * @class BaseService
###
class BaseService

  ###*
   * Initialize the class.
   * @constructor
   *
   * @param  {Rest} [_rest] An instance of the Rest client (sphere-node-connect)
  ###
  constructor: (@_rest)->
    ###*
     * @private
     * Base path for a API resource endpoint (to be overriden by specific service)
     * @type {String}
    ###
    @_projectEndpoint = '/'

  ###*
   * Fetch resource defined by [_projectEndpoint]
   * @return {Promise} A promise, fulfilled with an Object or rejected with a SphereError
  ###
  fetch: ->
    deferred = Q.defer()
    @_rest.GET @_projectEndpoint, (e, r, b)->
      # TODO: wrap / handle responses generally
      if e
        deferred.reject e
      else
        deferred.resolve JSON.parse b
    deferred.promise

###*
 * The {@link BaseService} service.
###
module.exports = BaseService