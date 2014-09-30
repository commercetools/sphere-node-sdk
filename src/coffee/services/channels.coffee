_ = require 'underscore'
_.mixin containsAll: (from, to) ->
  _.all from, (x) -> _.contains to, x
Promise = require 'bluebird'
BaseService = require './base'

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
   * Retrieves the first found channel result for a given key and roles.
   * If not existing, the channel will be created or the channel roles will be
   * added if absent.

   * @param {String} key A unique identifier for channel within the project.
   * @param {Array} roles A list of {ChannelRole} the channel must have.
   * @throws {Error} If a required argument is missing
   * @return {Promise} A promise, fulfilled with an {Object} or rejected with a {SphereError}
  ###
  ensure: (key, roles) ->
    throw new Error 'Key is required.'unless key
    throw new Error 'Role is required.'unless roles

    new Promise (resolve, reject) =>

      roles = _.flatten [roles]

      @_setDefaults()

      @where("key=\"#{key}\"").page(1).perPage(1)

      queryString = @_queryString()
      endpoint = "#{@_currentEndpoint}?#{@_queryString()}"

      @_get(endpoint)
      .then (result) =>
        if result.body.total is 1
          channel = result.body.results[0]
          if not _.containsAll roles, channel.roles
            update =
              version: channel.version
              actions: [
                { action: 'addRoles', roles: _.difference(roles, channel.roles) }
              ]
            resolve @byId(channel.id).update(update)
          else
            resolve
              statusCode: result.statusCode
              body: channel
        else if result.body.total is 0
          channel =
            key: key
            roles: roles
          resolve @save(channel)
        else
          reject new Error "#{result.body.total} channels with key = '#{key}' found (key should be unique for a project)."

      .catch (result) -> reject result

###*
 * The {@link ChannelService} service.
###
module.exports = ChannelService
