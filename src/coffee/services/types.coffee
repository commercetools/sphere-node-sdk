_ = require 'underscore'
BaseService = require './base'

# Public: Define a `TypeService` to interact with the HTTP [`types`](http://dev.sphere.io/http-api-projects-types.html) endpoint.
#
# _Types define custom fields that are used to enhance resources as you need._
#
# Examples
#
#   service = client.types
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
class TypeService extends BaseService

  # Internal: {String} The HTTP endpoint for `Types`
  @baseResourceEndpoint: '/types'

  @supportsByKey: true

module.exports = TypeService
