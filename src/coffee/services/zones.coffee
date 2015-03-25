BaseService = require './base'

# Public: Define a `ZoneService` to interact with the HTTP [`zones`](http://dev.sphere.io/http-api-projects-zones.html) endpoint.
#
# _Zones define Shipping Rates for a set of Locations._
#
# Examples
#
#   service = client.zones
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
class ZoneService extends BaseService

  # Internal: {String} The HTTP endpoint for `Zones`
  @baseResourceEndpoint: '/zones'

module.exports = ZoneService
