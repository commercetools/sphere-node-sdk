import {
  buildBaseAttributesActions,
  buildReferenceActions,
} from './utils/common-actions'

export const baseActionsList = [
  { action: 'setShipmentState', key: 'shipmentState' },
  { action: 'setPaymentState', key: 'paymentState' },
  { action: 'setOrderState', key: 'orderState' },
]

export const referenceActionsList = [
]

/**
 * SYNC FUNCTIONS
 */

export function actionsMapBase (diff, oldObj, newObj) {
  return buildBaseAttributesActions({
    actions: baseActionsList,
    diff,
    oldObj,
    newObj,
  })
}

export function actionsMapReferences (diff, oldObj, newObj) {
  return buildReferenceActions({
    actions: referenceActionsList,
    diff,
    oldObj,
    newObj,
  })
}

export function actionsMapAddresses (/* diff, oldObj, newObj */) {
  const actions = []
  return actions
}
