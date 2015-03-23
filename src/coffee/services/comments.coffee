BaseService = require './base'

# Public: Define a `CommentService` to interact with the HTTP [`comments`](http://dev.sphere.io/http-api-projects-comments.html) endpoint.
#
# _Comment on a product by a customer._
#
# Examples
#
#   service = client.comments()
#   service.save
#     productId: '111'
#     customerId: '222'
#     authorName: 'John Doe'
#     title: 'My Comment'
class CommentService extends BaseService

  # Internal: {String} The HTTP endpoint for `Comments`
  @baseResourceEndpoint: '/comments'

module.exports = CommentService
