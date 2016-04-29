BaseService = require './base'

# Public: Define a `ProjectService` to interact with the HTTP [`project`](http://dev.sphere.io/http-api-projects-project.html) endpoint.
# **Read-only!**
#
# _The Project endpoint is used to retrieve certain information from a project._
#
# Examples
#
#   service = client.project
#   service.fetch()
class ProjectService extends BaseService

  # Internal: {String} The HTTP endpoint for `Project`
  @baseResourceEndpoint: ''

  # Public Unsupported: Not supported by the API
  byKey: -> # noop

  # Public Unsupported: Not supported by the API
  save: ->

  # Public Unsupported: Not supported by the API
  create: ->

  # Public Unsupported: Not supported by the API
  update: ->

  # Public Unsupported: Not supported by the API
  delete: ->

module.exports = ProjectService
