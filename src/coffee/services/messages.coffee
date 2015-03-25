BaseService = require './base'

# Public: Define a `MessageService` to interact with the HTTP [`messages`](http://dev.sphere.io/http-api-projects-messages.html) endpoint.
# **Read-only!**
#
# _A message represent a change or an action performed on a resource (like an Order).
# Messages can be seen as a subset of the change history for a resource inside a project.
# It is a subset because not all changes on resources result in messages._
#
# Examples
#
#   service = client.messages
#   service.byId('123').fetch()
class MessageService extends BaseService

  # Internal: {String} The HTTP endpoint for `Messages`
  @baseResourceEndpoint: '/messages'

  # Public Unsupported: Not supported by the API
  save: -> # noop

  # Public Unsupported: Not supported by the API
  create: -> # noop

  # Public Unsupported: Not supported by the API
  update: -> # noop

  # Public Unsupported: Not supported by the API
  delete: -> # noop

module.exports = MessageService
