_ = require 'underscore'
jsondiffpatch = require 'jsondiffpatch'
BaseUtils = require './base'
helper = require '../helper'

###
Order Utils class
###
class OrderUtils extends BaseUtils

  ###
  Create list of actions for syncing order status values.
  @param {object} diff Result of jsondiffpatch tool.
  @param {object} old_obj Order to be updated.
  @return list with actions
  ###
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

  ###
  Create list of actions for syncing delivery items.
  @param {object} diff Result of jsondiffpatch tool.
  @param {object} old_obj Order to be updated.
  @return list with actions
  ###
  actionsMapDeliveries: (diff, old_obj) ->

    return [] unless _.has(diff, 'shippingInfo') and _.has(diff.shippingInfo, 'deliveries')
    # iterate over returnInfo instances
    actions = _.chain diff.shippingInfo.deliveries
      .filter (item, key) -> key isnt '_t'
      .map (deliveryDiff, deliveryIndex) ->
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
            .filter (item, key) -> key isnt '_t' and  _.isArray item
            .map (parcelDiff) ->
              # delivery was added
              parcel = _.last parcelDiff
              action =
                action: 'addParcelToDelivery'
                deliveryId: old_obj.shippingInfo.deliveries[deliveryIndex].id
              _.each parcel, (item, key) ->
                action[key] = item
              action
            .value()
      .value()
    _.flatten actions



  ###
  Create list of actions for syncing returnInfo items and returnInfo status values.
  @param {object} diff Result of jsondiffpatch tool.
  @param {object} old_obj Order to be updated.
  @return list with actions
  ###
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


###
Exports object
###
module.exports = OrderUtils

#################
# Order helper methods
#################

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
