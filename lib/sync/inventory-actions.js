import forEach from 'lodash.foreach'
import { buildBaseAttributesAction } from './utils/common-actions'
import * as diffpatcher from './utils/diffpatcher'

function actionsBaseList () {
  return [
    { action: 'changeQuantity', key: 'quantityOnStock', actionKey: 'quantity' },
    { action: 'setRestockableInDays', key: 'restockableInDays' },
    { action: 'setExpectedDelivery', key: 'expectedDelivery' },
  ]
}

/**
 * SYNC FUNCTIONS
 */

export function actionsMapBase (diff, oldObj, newObj) {
  const actions = []

  forEach(actionsBaseList(), item => {
    const action = buildBaseAttributesAction(
      item, diff, oldObj, newObj, diffpatcher.patch
    )
    if (action) actions.push(action)
  })

  return actions
}

export function actionsMapReferences (diff, oldObj, newObj) {
  const actions = []

  if (diff.supplyChannel && !(
    // If the only change relates to the expansion `obj`, simply ignore it.
    diff.supplyChannel.obj &&
    Object.keys(diff.supplyChannel).length === 1
  )) {
    const newValue = Array.isArray(diff.supplyChannel)
      ? diffpatcher.getDeltaValue(diff.supplyChannel)
      : newObj.supplyChannel

    actions.push({
      action: 'setSupplyChannel',
      supplyChannel: newValue,
    })
  }

  return actions
}
