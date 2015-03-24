BaseService = require './base'

# Public: Define a `CustomerGroupService` to interact with the HTTP [`customer-groups`](http://dev.sphere.io/http-api-projects-customerGroups.html) endpoint.
#
# _A Customer can be a member of several customer groups (e.g. reseller, gold member).
# Special prices can be assigned to specific products based on a customer group._
#
# Examples
#
#   service = client.customerGroups()
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
class CustomerGroupService extends BaseService

  # Internal: {String} The HTTP endpoint for `CustomerGroups`
  @baseResourceEndpoint: '/customer-groups'

module.exports = CustomerGroupService
