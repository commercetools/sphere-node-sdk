BaseService = require './base'

# Public: Define a `CustomObjectService` to interact with the HTTP [`custom-objects`](http://dev.sphere.io/http-api-projects-custom-objects.html) endpoint.
#
# _Store custom JSON values._
#
# Examples
#
#   service = client.customObjects
#   service.save
#     container: 'myNamespace'
#     key: 'myKey'
#     value:
#       foo: 'bar'
#       counts: [1, 2, 3, 4, 5]
#
#   service.fetch('myNamespace/myKey')
class CustomObjectService extends BaseService

  # Internal: {String} The HTTP endpoint for `CustomObjects`
  @baseResourceEndpoint: '/custom-objects'

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

module.exports = CustomObjectService
