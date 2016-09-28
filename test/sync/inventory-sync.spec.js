import test from 'tape'
import inventorySyncFn, { actionGroups } from '../../src/sync/inventories'
import {
  baseActionsList,
  referenceActionsList,
} from '../../src/sync/inventory-actions'

test('Sync::inventory', (t) => {
  let inventorySync
  function setup () {
    inventorySync = inventorySyncFn()
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
        {
          action: 'changeQuantity',
          key: 'quantityOnStock',
          actionKey: 'quantity',
        },
        { action: 'setRestockableInDays', key: 'restockableInDays' },
        { action: 'setExpectedDelivery', key: 'expectedDelivery' },
      ],
      'correctly define base actions list'
    )

    t.deepEqual(
      referenceActionsList,
      [
        { action: 'setSupplyChannel', key: 'supplyChannel' },
      ],
      'correctly define reference actions list'
    )

    t.end()
  })

  t.test('should build `changeQuantity` action', (t) => {
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
})
