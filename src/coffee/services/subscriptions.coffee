BaseService = require './base'

# IMPORTANT:
# THIS FEATURE IS FOR INTERNAL USE ONLY.
# MIGHT BE REMOVED IN THE FUTURE.
# PLEASE DON'T USE THIS ENDPOINT.
class Subscriptions extends BaseService

  # Internal: {String} The HTTP endpoint for `Subscriptions`
  @baseResourceEndpoint: '/subscriptions'

module.exports = Subscriptions
