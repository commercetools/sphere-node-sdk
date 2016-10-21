import test from 'tape'
import ordersSyncFn, { actionGroups } from '../../src/sync/order'
import {
  baseActionsList,
  referenceActionsList,
} from '../../src/sync/order-actions'

test.only('Sync::order', (t) => {
  let ordersSync
  function setup () {
    ordersSync = ordersSyncFn()
  }

  t.test('should export action group list', (t) => {
    t.deepEqual(actionGroups, [
      'base', 'references',
    ])
    t.end()
  })

  t.test('should define action lists', (t) => {
    t.deepEqual(
      baseActionsList,
      [
        { action: 'setShipmentState', key: 'shipmentState' },
        { action: 'setPaymentState', key: 'paymentState' },
        { action: 'setOrderState', key: 'orderState' },
      ],
      'correctly define base actions list'
    )

    t.deepEqual(
      referenceActionsList,
      [],
      'correctly define reference actions list'
    )

    t.end()
  })

  t.test('should build `setShipmentState` action', (t) => {
    setup()

    const before = {
      shipmentState: 'Shipped',
    }
    const now = {
      shipmentState: 'Ready',
    }

    const actual = ordersSync.buildActions(now, before)
    const expected = [{ action: 'setShipmentState', shipmentState: 'Ready' }]
    t.deepEqual(actual, expected)

    t.end()
  })

  t.test('should build `setPaymentState` action', (t) => {
    setup()

    const before = {
      paymentState: 'BalanceDue',
    }
    const now = {
      paymentState: 'Paid',
    }

    const actual = ordersSync.buildActions(now, before)
    const expected = [{ action: 'setPaymentState', paymentState: 'Paid' }]
    t.deepEqual(actual, expected)

    t.end()
  })

  t.test('should build `setOrderState` action', (t) => {
    setup()

    const before = {
      orderState: 'Open',
    }
    const now = {
      orderState: 'Confirmed',
    }

    const actual = ordersSync.buildActions(now, before)
    const expected = [{ action: 'setOrderState', orderState: 'Confirmed' }]
    t.deepEqual(actual, expected)

    t.end()
  })
})
