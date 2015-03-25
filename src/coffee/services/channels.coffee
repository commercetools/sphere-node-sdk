_ = require 'underscore'
_.mixin containsAll: (from, to) ->
  _.all from, (x) -> _.contains to, x
Promise = require 'bluebird'
BaseService = require './base'

# Public: Define a `ChannelService` to interact with the HTTP [`channels`](http://dev.sphere.io/http-api-projects-channels.html) endpoint.
#
# _Channels represent a source or destination of different entities._
#
# Examples
#
#   service = client.channels
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'changeName'
#           name:
#             en: 'Foo'
#         }
#       ]
class ChannelService extends BaseService

  # Internal: {String} The HTTP endpoint for `Channels`
  @baseResourceEndpoint: '/channels'

  # Public: Ensure a `channel` exists. It tries fetching one with given `key`, if not found
  # it will create one otherwise will update it. Given `roles` are also ensured to exist.
  #
  # key - {String} A unique identifier for `channel` within the project
  # roles - {Array} A list of [ChannelRole](http://dev.sphere.io/http-api-projects-channels.html#channel-role-enum)
  #         the `channel` must have
  #
  # Throws an {Error} if `key` and `roles` are missing
  #
  # Returns a {Promise}, fulfilled with an {Object} or rejected with an instance of an {Error}
  #
  # Examples
  #
  #   service = client.channels
  #   roles = ['InventorySupply', 'OrderImport']
  #   service.ensure('foo', roles)
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

module.exports = ChannelService
