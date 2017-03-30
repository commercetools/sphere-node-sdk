BaseService = require './base'

# Public: Define a `SubscriptionService` to interact with the HTTP [`subscriptions`](http://dev.commercetools.com/http-api-projects-subscriptions.html) endpoint.
#
# Subscriptions are used to trigger an asynchronous background process in response to an event on the commercetools™ platform.
#
# Examples
#
#   service = client.subscriptions
#   service.byId('123').fetch()
#   .then (result) ->
#     service.byId('123').update
#       version: result.body.version
#       actions: [
#         {
#           action: 'setKey'
#           key: 'Foo'
#         }
#       ]
class Subscriptions extends BaseService

  # Internal: {String} The HTTP endpoint for `Subscriptions`
  @baseResourceEndpoint: '/subscriptions'

  @supportsByKey: true

module.exports = Subscriptions
