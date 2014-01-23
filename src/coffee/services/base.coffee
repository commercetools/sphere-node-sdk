Q = require('q')

###*
 * Creates a new BaseService, containing base functionalities. It should be extended when defining a Service.
 * @class BaseService
###
class BaseService

  ###*
   * Initialize the class.
   * @param  {Rest} [@_rest] an instance of the Rest client (sphere-node-connect)
   * @return {BaseService}
  ###
  constructor: (@_rest)->
    @_projectEndpoint = '/'
    @

  ###*
   * Fetch resource defined by [@_projectEndpoint]
   * @return {Promise} a promise, fulfilled with an Object or rejected with a SphereError
  ###
  fetch: ->
    deferred = Q.defer()
    @_rest @_projectEndpoint, (e, r, b)->
      if e
        deferred.reject e
      else
        deferred.resolve JSON.parse b
    deferred.promise

###*
 * The {@link BaseService} service.
###
module.exports = BaseService