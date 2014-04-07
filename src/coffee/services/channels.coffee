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
   * Retrieves the first found channel result for a given key and role.
   * If not existing, the channel will be created or the channel role will be
   * added if absent.
   
   * @param {String} key Channel needs to have this key.
   * @param {String} role Channel needs to have this role.
   * @return {Promise Result}
  ###
  byKeyOrCreate: (key, role) ->
    deferred = Q.defer()

    @client.channels
    .where("key=\"#{key}\"")
    .page(1).fetch()
    .then (result) =>
      if result.body.total is 1
        channel = result.body.results[0]
        if role not in channel.roles
          update =
            version: channel.version
            actions: [
              {
                action: 'addRoles'
                roles: role
              }
            ]

          deferred.resolve @client.channels.byId(channel.id).update(update)
        else
          deferred.resolve result
      else
        channel =
          key: key
          roles: [role]
        deferred.resolve @client.channels.save(channel)

    .fail (result) ->
      deferred.reject result

    deferred.promise

###*
 * The {@link ChannelService} service.
###
module.exports = ChannelService
