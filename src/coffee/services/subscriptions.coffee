BaseService = require './base'

class Subscriptions extends BaseService

  # Internal: {String} The HTTP endpoint for `Subscriptions`
  @baseResourceEndpoint: '/subscriptions'

module.exports = Subscriptions
