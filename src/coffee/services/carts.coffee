BaseService = require './base'

# Public: CartService
class CartService extends BaseService

  # Internal: Base path for a Carts API resource endpoint ({String})
  @baseResourceEndpoint: '/carts'

module.exports = CartService
