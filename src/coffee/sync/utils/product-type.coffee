_ = require 'underscore'
BaseUtils = require './base'

# Private: utilities for product type sync
class ProductTypeUtils extends BaseUtils

  # Private: map enum value actions
  actionsForEnumValues: (diff, new_product_type) ->
    actions = []
    if diff
      actions.push { action : 'addPlainEnumValue', name : 'size', value : 'S' }
    actions

module.exports = ProductTypeUtils