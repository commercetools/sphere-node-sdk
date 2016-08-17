import test from 'tape'
import inventorySyncFn, { actionGroups } from '../../src/sync/inventories'

test('Sync::inventory', t => {
  let inventorySync
  function setup () {
    inventorySync = inventorySyncFn()
  }

  t.test('should export action group list', t => {
    t.deepEqual(actionGroups, [
      'base', 'references',
    ])
    t.end()
  })

  t.test('should build `changeQuantity` action', t => {
    setup()

    const before = {
      quantityOnStock: 1,
    }
    const now = {
      quantityOnStock: 2,
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [{ action: 'changeQuantity', quantity: 2 }]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `changeQuantity` for negative values', t => {
    setup()

    const before = {
      quantityOnStock: 10,
    }
    const now = {
      quantityOnStock: -5,
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [{ action: 'changeQuantity', quantity: -5 }]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setRestockableInDays` action', t => {
    setup()

    const before = {}
    const now = {
      restockableInDays: 10,
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setRestockableInDays' }, now),
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setRestockableInDays` action (unset)', t => {
    setup()

    const before = {
      restockableInDays: 10,
    }
    const now = {
      restockableInDays: null,
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [{ action: 'setRestockableInDays' }]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setExpectedDelivery` action', t => {
    setup()

    const before = {}
    const now = {
      expectedDelivery: '2016-07-15T16:35:50.107Z',
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setExpectedDelivery' }, now),
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setExpectedDelivery` action (unset)', t => {
    setup()

    const before = {
      expectedDelivery: '2016-07-15T16:35:50.107Z',
    }
    const now = {
      expectedDelivery: null,
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [{ action: 'setExpectedDelivery' }]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setSupplyChannel` action', t => {
    setup()

    const before = {}
    const now = {
      supplyChannel: {
        id: '1',
        typeId: 'channel',
      },
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [
      Object.assign({ action: 'setSupplyChannel' }, now),
    ]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should build `setSupplyChannel` action (unset)', t => {
    setup()

    const before = {
      supplyChannel: {
        id: '1',
        typeId: 'channel',
      },
    }
    const now = {
      supplyChannel: null,
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = [{ action: 'setSupplyChannel', supplyChannel: null }]
    t.deepEqual(actual, expected)
    t.end()
  })

  t.test('should ignore expansion for existing `supplyChannel`', t => {
    setup()

    const before = {
      supplyChannel: {
        id: '1',
        typeId: 'channel',
        obj: {
          id: '1',
        },
      },
    }
    const now = {
      supplyChannel: {
        id: '1',
        typeId: 'channel',
      },
    }
    const actual = inventorySync.buildActions(now, before)
    const expected = []
    t.deepEqual(actual, expected)
    t.end()
  })
})
