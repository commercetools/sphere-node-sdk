_ = require 'underscore'
BaseSync = require './base-sync'
InventoryUtils = require './utils/inventory'

# Public: Define a `InventorySync` to provide basic methods to sync SPHERE.IO inventory entries.
#
# Action groups for products are:
# - `quantity`
# - `expectedDelivery`
# - `custom`
#
# Examples
#
#   {InventorySync} = require 'sphere-node-sdk'
#   sync = new InventorySync
#   syncedActions = sync.buildActions(newInventory, existingInventory)
#   if syncedActions.shouldUpdate()
#     client.inventoryEntries.byId(syncedActions.getUpdatedId())
#     .update(syncedActions.getUpdatePayload())
#   else
#     # do nothing
class InventorySync extends BaseSync

  @actionGroups = ['quantity', 'expectedDelivery', 'custom']

  # Public: Construct a `InventorySync` object.
  constructor: ->
    # Override base utils
    @_utils = new InventoryUtils

  _doMapActions: (diff, new_obj, old_obj) ->
    allActions = []
    allActions.push @_mapActionOrNot 'quantity', => @_utils.actionsMapQuantity(diff, old_obj)
    allActions.push @_mapActionOrNot 'expectedDelivery', => @_utils.actionsMapExpectedDelivery(diff, old_obj)
    allActions.push @_mapActionOrNot 'custom', => @_utils.actionsMapCustom(diff, old_obj, new_obj)
    _.flatten allActions

module.exports = InventorySync
