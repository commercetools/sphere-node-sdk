BaseService = require './base'

# Public: Define a `InventoryEntryService` to interact with the HTTP [`inventory`](http://dev.sphere.io/http-api-projects-inventory.html) endpoint.
#
# _Inventory allows you to track stock quantities._
#
# Examples
#
#   service = client.inventoryEntries
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'addQuantity'
#           quantity: 10
#         }
#       ]
class InventoryEntryService extends BaseService

  # Internal: {String} The HTTP endpoint for `InventoryEntries`
  @baseResourceEndpoint: '/inventory'

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

module.exports = InventoryEntryService
