BaseService = require './base'

# Public: Define a `CategoryService` to interact with the HTTP [`categories`](http://dev.sphere.io/http-api-projects-categories.html) endpoint.
#
# _Categories are used to organize products in a hierarchical structure._
#
# Examples
#
#   service = client.categories
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
class CategoryService extends BaseService

  # Internal: {String} The HTTP endpoint for `Categories`
  @baseResourceEndpoint: '/categories'

module.exports = CategoryService
