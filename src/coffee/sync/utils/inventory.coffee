_ = require 'underscore'
BaseUtils = require './base'

# Private: utilities for inventory sync
class InventoryUtils extends BaseUtils

  # Private: map inventory quantities
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing inventory
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapQuantity: (diff, old_obj) ->
    actions = []
    if diff.quantityOnStock
      if _.isArray(diff.quantityOnStock) and _.size(diff.quantityOnStock) is 2
        oldVal = diff.quantityOnStock[0]
        newVal = diff.quantityOnStock[1]
        diffVal = newVal - oldVal
        a =
          quantity: Math.abs diffVal
        if diffVal > 0
          a.action = 'addQuantity'
          actions.push a
        else if diffVal < 0
          a.action = 'removeQuantity'
          actions.push a
    actions

  # Private: map inventory expected deliveries
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing inventory
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapExpectedDelivery: (diff, old_obj) ->
    actions = []
    if diff.expectedDelivery
      if _.isArray(diff.expectedDelivery)
        size = _.size(diff.expectedDelivery)
        a =
          action: 'setExpectedDelivery'
        if size is 1
          a.expectedDelivery = diff.expectedDelivery[0]
        else if size is 2
          a.expectedDelivery = diff.expectedDelivery[1]
        # Delete case (size is 3) - we do not set any expectedDelivery
        actions.push a
    actions

  # Private: map inventory custom type and fields
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing inventory
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapCustom: (diff, old_obj, new_obj) =>
    actions = []
    if !diff.custom
      return actions

    # if custom is new in itself it's placed in an array we need to unwrap
    if Array.isArray(diff.custom)
      diff.custom = diff.custom[0]

    # if custom's type is new it's placed in an array we need to unwrap
    if diff.custom.type
      diff.custom.type = diff.custom.type[0] || diff.custom.type

    if diff.custom.type && diff.custom.type.id
      actions.push
        action: 'setCustomType'
        type:
          typeId: 'type',
          id: if Array.isArray(diff.custom.type.id) then @getDeltaValue(diff.custom.type.id) else diff.custom.type.id
        fields: if Array.isArray(diff.custom.fields) then @getDeltaValue(diff.custom.fields) else diff.custom.fields
    else if diff.custom.fields
      customFieldsActions = Object.keys(diff.custom.fields).map((name) =>
        {
          action: 'setCustomField'
          name: name
          value: if Array.isArray(diff.custom.fields[name]) then @getDeltaValue(diff.custom.fields[name]) else new_obj.custom.fields[name]
        }
      )
      actions = actions.concat(customFieldsActions)
    actions

module.exports = InventoryUtils
