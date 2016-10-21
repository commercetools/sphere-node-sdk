import test from 'tape'
import orderSyncFn, { actionGroups } from '../../src/sync/orders'
import {
  baseActionsList,
} from '../../src/sync/order-actions'

test('Sync::order', (t) => {
  let orderSync
  function setup () {
    orderSync = orderSyncFn()
  }

  t.test('should export action group list', (t) => {
    t.deepEqual(actionGroups, [
      'base',
    ])
    t.end()
  })

  t.test('should define action lists', (t) => {
    t.deepEqual(
      baseActionsList,
      [
        { action: 'changeOrderState', key: 'orderState' },
        { action: 'changePaymentState', key: 'paymentState' },
        { action: 'changeShipmentState', key: 'shipmentState' },
      ],
      'correctly define base actions list'
    )

    t.end()
  })

  t.test('should build *state actions', (t) => {
    setup()

    const before = {
      orderState: 'Open',
      paymentState: 'Pending',
      shipmentState: 'Ready',
    }
    const now = {
      orderState: 'Complete',
      paymentState: 'Paid',
      shipmentState: 'Shipped',
    }

    const actual = orderSync.buildActions(now, before)
    const expected = [
      { action: 'changeOrderState', orderState: 'Complete' },
      { action: 'changePaymentState', paymentState: 'Paid' },
      { action: 'changeShipmentState', shipmentState: 'Shipped' },
    ]
    t.deepEqual(actual, expected)

    t.end()
  })
})
