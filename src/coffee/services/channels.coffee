BaseService = require './base'
Q = require 'q'

###*
 * Creates a new ChannelService.
 * @class ChannelService
###
class ChannelService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Channels API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/channels'


  ###*
   * Retrieves the first found channel result for a given key and role.
   * If not existing, the channel will be created or the channel role will be
   * added if absent.

   * @param {String} key A unique identifier for channel within the project.
   * @param {ChannelRole} role The ChannelRole the channel must have ().
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with
   *           a {SphereError}
  ###
  ensure: (key, role) ->

    deferred = Q.defer()

    unless key
      deferred.reject new Error 'Key is required.'
      return deferred.promise

    unless role
      deferred.reject new Error 'Role is required.'
      return deferred.promise

    @where("key=\"#{key}\"")
      .page(1).perPage(1)

    queryString = @_queryString()
    endpoint = "#{@_currentEndpoint}?#{@_queryString()}"

    @_get(endpoint)
    .then (result) =>
      if result.body.total is 1
        channel = result.body.results[0]
        if role not in channel.roles
          update =
            version: channel.version
            actions: [
              {
                action: 'addRoles'
                roles: [role]
              }
            ]
          deferred.resolve @byId(channel.id).update(update)
        else
          deferred.resolve
            statusCode: result.statusCode
            body: channel
      else if result.body.total is 0
        channel =
          key: key
          roles: [role]
        deferred.resolve @save(channel)
      else
        deferred.reject new Error "#{result.body.total} channels with key = '#{key}' found (key should be unique for a project)."

    .fail (result) ->
      deferred.reject result

    deferred.promise

###*
 * The {@link ChannelService} service.
###
module.exports = ChannelService
