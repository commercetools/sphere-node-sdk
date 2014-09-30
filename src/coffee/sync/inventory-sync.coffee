_ = require 'underscore'
BaseSync = require './base-sync'
InventoryUtils = require './utils/inventory'

###*
 * Inventory Sync class
###
class InventorySync extends BaseSync

  constructor: ->
    # Override base utils
    @_utils = new InventoryUtils

  ###*
   * @override
  ###
  _doMapActions: (diff, new_obj, old_obj) ->
    allActions = []
    allActions.push @_mapActionOrNot 'quantity', => @_utils.actionsMapQuantity(diff, old_obj)
    allActions.push @_mapActionOrNot 'expectedDelivery', => @_utils.actionsMapExpectedDelivery(diff, old_obj)
    _.flatten allActions

module.exports = InventorySync
