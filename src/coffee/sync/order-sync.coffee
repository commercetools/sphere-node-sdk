_ = require 'underscore'
BaseSync = require './base-sync'
OrderUtils = require './utils/order'

# Public: Define a `OrderSync` to provide basic methods to sync SPHERE.IO orders.
#
# Action groups for products are:
# - `status` (orderState, paymentState, shipmentState)
# - `returnInfo` (returnInfo, shipmentState / paymentState of ReturnInfo)
# - `deliveries` (delivery, parcel)
# - `lineItems`
#
# Examples
#
#   {OrderSync} = require 'sphere-node-sdk'
#   sync = new OrderSync
#   syncedActions = sync.buildActions(newCategory, existingCategory)
#   if syncedActions.shouldUpdate()
#     client.orders.byId(syncedActions.getUpdatedId())
#     .update(syncedActions.getUpdatePayload())
#   else
#     # do nothing
class OrderSync extends BaseSync

  @actionGroups = ['status', 'returnInfo', 'deliveries', 'lineItems']

  # Public: Construct a `OrderSync` object.
  constructor: ->
    # Override base utils
    @_utils = new OrderUtils

  _doMapActions: (diff, new_obj, old_obj) ->
    allActions = []
    allActions.push @_mapActionOrNot 'status', => @_utils.actionsMapStatusValues(diff, old_obj)
    allActions.push @_mapActionOrNot 'returnInfo', => @_utils.actionsMapReturnInfo(diff, old_obj)
    allActions.push @_mapActionOrNot 'deliveries', => @_utils.actionsMapDeliveries(diff, old_obj)
    allActions.push @_mapActionOrNot 'lineItems', => @_utils.actionsMapLineItems(diff, old_obj, new_obj)
    _.flatten allActions

module.exports = OrderSync
