BaseService = require './base'

# Public: Define a `ProductService` to interact with the HTTP [`products`](http://dev.sphere.io/http-api-projects-products.html) endpoint.
# A [`Product`](http://dev.sphere.io/http-api-projects-products.html#product) contains a `current` and `staged` version
# in a single representation.
#
# _Products are the sellable goods in an e-commerce project on SPHERE.IO. This document explains some design concepts of products
# on SPHERE.IO and describes the available HTTP APIs for working with them._
#
# Examples
#
#   service = client.products()
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
class ProductService extends BaseService

  # Internal: {String} The HTTP endpoint for `Products`
  @baseResourceEndpoint: '/products'

module.exports = ProductService
