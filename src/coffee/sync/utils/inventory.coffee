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

module.exports = InventoryUtils
