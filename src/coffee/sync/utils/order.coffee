_ = require 'underscore'
BaseUtils = require './base'

# Private: utilities for order sync
class OrderUtils extends BaseUtils

  # Private: configure the diff function
  diff: (old_obj, new_obj) ->
    patchReturnInfos = (order) ->
      _.each order.returnInfo, (info, index) ->
        info._MATCH_CRITERIA = "#{index}"

    patchReturnInfos old_obj
    patchReturnInfos new_obj

    super old_obj, new_obj

  # Private: map order statuses
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing order
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapStatusValues: (diff, old_obj) ->
    actions = []
    _.each actionsList(), (item) =>
      key = item.key
      obj = diff[key]
      if obj
        updated = @getDeltaValue(obj)
        action =
          action: item.action
        action[key] = updated

      actions.push action if action
    actions

  # Private: map order deliveries
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # new_obj - {Object} The new order
  # old_obj - {Object} The old order
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapDeliveries: (diff, new_obj, old_obj) ->
    newDeliveries = new_obj.shippingInfo?.deliveries or []
    oldDeliveries = old_obj.shippingInfo.deliveries

    return [] unless _.has(diff, 'shippingInfo') and _.has(diff.shippingInfo, 'deliveries')
    # iterate over returnInfo instances
    actions = _.chain diff.shippingInfo.deliveries
      .filter (item, key) -> key[0] isnt '_' # ignore _t and all removed items
      .map (deliveryDiff) ->
        if _.isArray deliveryDiff
          # delivery was added
          delivery = _.last deliveryDiff
          action =
            action: 'addDelivery'
          _.each _.keys(delivery), (key) ->
            action[key] = delivery[key]
          action
        else
          # iterate over parcel instances
          _.chain deliveryDiff.parcels
            # keys starting with an underscore are:
            # - _t - internal jsondiffpatch property
            # - _N - removed keys where N is an index of a removed item
            # We do not support removed deliveries so we filter out all
            # keys starting with an underscore "_"
            .filter (item, key) -> key[0] isnt '_' and  _.isArray item
            .map (parcelDiff) ->
              # delivery was added
              parcel = _.last parcelDiff
              deliveryId = findDeliveryIdByParcel(
                newDeliveries,
                oldDeliveries,
                parcel
              )

              action =
                action: 'addParcelToDelivery'
                deliveryId: deliveryId
              _.each parcel, (item, key) ->
                action[key] = item
              action
            .value()
      .value()
    _.flatten actions

  # Private: map order returns
  #
  # diff - {Object} The result of diff from `jsondiffpatch`
  # old_obj - {Object} The existing order
  #
  # Returns {Array} The list of actions, or empty if there are none
  actionsMapReturnInfo: (diff, old_obj) ->

    return [] unless _.has(diff, 'returnInfo')
    # iterate over returnInfo instances
    actions = _.chain diff['returnInfo']
      .filter (item, key) -> key isnt '_t'
      .map (returnInfoDelta, returnInfoDeltaKey) =>
        if _.isArray returnInfoDelta
          # get last added item
          returnInfo = _.last returnInfoDelta
          action =
            action: 'addReturnInfo'
          _.each returnInfo, (value, key) ->
            action[key] = value
          action

          # TODO: split into multiple actions (addReturnInfo + setReturnShipmentState/setReturnPaymentState)
          #   in case shipmentState/paymentState already transitioned to a non-initial state
        else
          returnInfo = returnInfoDelta
          # iterate over returnItem instances
          actions = _.chain returnInfo.items
            .filter (item, key) -> key isnt '_t'
            .map (item, itemKey) =>
              # iterate over all returnInfo status actions
              _.chain actionsListReturnInfoState()
                .filter (actionDefinition) -> _.has(item, actionDefinition.key)
                .map (actionDefinition) =>
                  action =
                    action: actionDefinition.action
                    returnItemId: old_obj.returnInfo[returnInfoDeltaKey].items[itemKey].id
                  action[actionDefinition.key] = @getDeltaValue item[actionDefinition.key]
                  action
                .value()
            .value()
      .value()
    _.flatten actions

module.exports = OrderUtils

#################
# Order helper methods
#################

# When adding new parcel, loop through newDeliveries and take ID from a delivery
# which has a new parcel and is in oldDeliveries
findDeliveryIdByParcel = (newDeliveries, oldDeliveries, newParcel) ->
  oldDeliveryIds = oldDeliveries.map (delivery) -> delivery.id
  for newDelivery in newDeliveries
    if newDelivery.parcels
      for oldParcel in newDelivery.parcels
        # find a correct existing delivery where we are adding new parcel
        if _.isEqual(oldParcel, newParcel) and newDelivery.id in oldDeliveryIds
          # and return its id
          return newDelivery.id

actionsList = ->
  [
    {
      action: 'changeOrderState'
      key: 'orderState'
    },
    {
      action: 'changePaymentState'
      key: 'paymentState'
    },
    {
      action: 'changeShipmentState'
      key: 'shipmentState'
    }
  ]

actionsListReturnInfoState = ->
  [
    {
      action: 'setReturnShipmentState'
      key: 'shipmentState'
    },
    {
      action: 'setReturnPaymentState'
      key: 'paymentState'
    }
  ]
