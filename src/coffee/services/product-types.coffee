BaseService = require './base'

# Public: Define a `ProductTypeService` to interact with the HTTP [`product-types`](http://dev.sphere.io/http-api-projects-productTypes.html) endpoint.
#
# _Product types are used to describe common characteristics, most importantly common custom attributes, of many concrete products._
#
# Examples
#
#   service = client.productTypes()
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
class ProductTypeService extends BaseService

  # Internal: {String} The HTTP endpoint for `ProductTypes`
  @baseResourceEndpoint: '/product-types'

module.exports = ProductTypeService
