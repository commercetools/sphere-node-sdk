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
            if not _.isArray value
              _.each value.values, (v, k) ->
                if k.match(/^\d+$/)
                  a =
                    name: new_product_type.attributes[key].name
                    value:
                      key: v[0]
                  if new_product_type.attributes[key].type.name is 'lenum'
                    a.action = 'addLocalizedEnumValue'
                    a.value.label =
                      en: "Label for #{v[0]}"
                  else
                    a.action = 'addPlainEnumValue'
                    a.value.label = "Label for #{v[0]}"
                  actions.push a

    actions

module.exports = ProductTypeUtils
