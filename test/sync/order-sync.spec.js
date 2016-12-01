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
      'deliveries',
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

  t.test('should build `addDelivery` action', (t) => {
    setup()

    const before = {
      shippingInfo: {
        deliveries: [],
      },
    }
    const now = {
      shippingInfo: {
        deliveries: [
          {
            items: [
              { id: 'li-1', qty: 1 },
              { id: 'li-2', qty: 2 },
            ],
            parcels: [{
              measurements: {
                heightInMillimeter: 1,
                lengthInMillimeter: 1,
                widthInMillimeter: 1,
                weightInGram: 1,
              },
              trackingData: {
                trackingId: '111',
              },
            }],
          },
        ],
      },
    }

    const actual = orderSync.buildActions(now, before)
    const expected = [{
      action: 'addDelivery',
      items: now.shippingInfo.deliveries[0].items,
      parcels: now.shippingInfo.deliveries[0].parcels,
    }]
    t.deepEqual(actual, expected, 'should create `addDelivery` action')
    t.end()
  })
})
