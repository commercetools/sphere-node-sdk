BaseService = require './base'

# Public: Define a `ReviewService` to interact with the HTTP [`reviews`](http://dev.sphere.io/http-api-projects-reviews.html) endpoint.
#
# _Review of a product by a customer. A customer can create only one review per product._
#
# Examples
#
#   service = client.reviews
#   service.save
#     productId: '111'
#     customerId: '222'
#     authorName: 'John Doe'
#     title: 'My review'
class ReviewService extends BaseService

  # Internal: {String} The HTTP endpoint for `Reviews`
  @baseResourceEndpoint: '/reviews'

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

  # Public Unsupported: Not supported by the API
  delete: ->

module.exports = ReviewService
