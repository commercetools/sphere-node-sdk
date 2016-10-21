import {
  buildBaseAttributesActions,
} from './utils/common-actions'

export const baseActionsList = [
  { action: 'changeOrderState', key: 'orderState' },
  { action: 'changePaymentState', key: 'paymentState' },
  { action: 'changeShipmentState', key: 'shipmentState' },
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
