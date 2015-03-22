_ = require 'underscore'
BaseUtils = require './base'

###
Inventory Utils class
###
class InventoryUtils extends BaseUtils

  ###
  Create list of actions for syncing inventory quantities.
  @param {Object} diff Result of jsondiffpatch tool.
  @param {Object} old_obj Inventory to be updated.
  @return {Array} The list of actions, or empty if there are none
  ###
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

  ###
  Create list of actions for syncing inventory expected deliveries.
  @param {Object} diff Result of jsondiffpatch tool.
  @param {Object} old_obj Inventory to be updated.
  @return {Array} The list of actions, or empty if there are none
  ###
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


###
Exports object
###
module.exports = InventoryUtils
