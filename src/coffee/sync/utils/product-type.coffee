_ = require 'underscore'
BaseUtils = require './base'

# Private: utilities for product type sync
class ProductTypeUtils extends BaseUtils

  # Private: map enum value actions
  actionsForEnumValues: (diff, new_product_type) ->
    actions = []
    if diff
      if diff.attributes
        _.each diff.attributes, (value, key) ->
          if key.match(/^\d+$/)
            if _.isArray value
              actions.push { action: 'addPlainEnumValue', name: value[0].name, value: value[0].values }
            else
              _.each value.values, (v, k) ->
                if k.match(/^\d+$/)
                  actions.push { action: 'addPlainEnumValue', name: new_product_type.attributes[key].name, value: { key: v[0], label: "Label for #{v[0]}"} }

    actions

module.exports = ProductTypeUtils
