BaseService = require('./base')

###*
 * Creates a new CommentService.
 * @class CommentService
###
class CommentService extends BaseService

  ###*
   * @const
   * @private
   * Base path for a Comments API resource endpoint
   * @type {String}
  ###
  @baseResourceEndpoint: '/comments'

###*
 * The {@link CommentService} service.
###
module.exports = CommentService
