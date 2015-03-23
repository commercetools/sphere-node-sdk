BaseService = require './base'

# Public: Define a `StateService` to interact with the HTTP [`states`](http://dev.sphere.io/http-api-projects-states.html) endpoint.
#
# _A State represents a state of a particular entity (defines a finite state machine).
# States can be combined together by defining transitions between each state, thus allowing to create work-flows._
#
# Examples
#
#   service = client.states()
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'setName'
#           name:
#             en: 'Foo'
#         }
#       ]
class StateService extends BaseService

  # Internal: {String} The HTTP endpoint for `States`
  @baseResourceEndpoint: '/states'

module.exports = StateService
