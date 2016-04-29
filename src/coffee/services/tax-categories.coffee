BaseService = require './base'

# Public: Define a `TaxCategoryService` to interact with the HTTP [`tax-categories`](http://dev.sphere.io/http-api-projects-taxCategories.html) endpoint.
#
# _Tax Categories define how products are to be taxed in different countries._
#
# Examples
#
#   service = client.taxCategories
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
class TaxCategoryService extends BaseService

  # Internal: {String} The HTTP endpoint for `TaxCategories`
  @baseResourceEndpoint: '/tax-categories'

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

module.exports = TaxCategoryService
