BaseService = require './base'

# Public: Define a `ProjectService` to interact with the HTTP [`project`](http://dev.sphere.io/http-api-projects-project.html) endpoint.
# **Read-only!**
#
# _The Project endpoint is used to retrieve certain information from a project._
#
# Examples
#
#   service = client.project()
#   service.fetch()
class ProjectService extends BaseService

  # Internal: {String} The HTTP endpoint for `Project`
  @baseResourceEndpoint: ''

  # Public: Not supported by the API
  save: ->

  # Public: Not supported by the API
  update: ->

  # Public: Not supported by the API
  delete: ->

module.exports = ProjectService
