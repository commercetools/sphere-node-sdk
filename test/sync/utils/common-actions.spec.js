import test from 'tape'
import {
  buildBaseAttributesActions,
  buildReferenceActions,
} from '../../../src/sync/utils/common-actions'
import * as diffpatcher from '../../../src/sync/utils/diffpatcher'

test('Sync::utils::commons', (t) => {
  t.test('::buildBaseAttributesActions', (t) => {
    const testActions = [
      { action: 'changeName', key: 'name' },
      { action: 'setDescription', key: 'description' },
      { action: 'setExternalId', key: 'externalId' },
      { action: 'changeSlug', key: 'slug' },
      { action: 'setCustomerNumber', key: 'customerNumber' },
    ]

    t.test('should build base actions', (t) => {
      const before = {
        name: { en: 'Foo' },
        description: undefined,
        externalId: '123',
        slug: { en: 'foo' },
        customerNumber: undefined,
      }
      const now = {
        name: { en: 'Foo1', de: 'Foo2' },
        description: { en: 'foo bar' },
        externalId: null,
        slug: { en: 'foo' },
        customerNumber: null,
      }

      const actions = buildBaseAttributesActions({
        actions: testActions,
        diff: diffpatcher.diff(before, now),
        oldObj: before,
        newObj: now,
      })

      t.deepEqual(
        actions,
        [
          { action: 'changeName', name: now.name },
          { action: 'setDescription', description: now.description },
          { action: 'setExternalId' },
        ],
        'build correct update actions'
      )

      t.end()
    })
  })

  t.test('::buildReferenceActions', (t) => {
    const testActions = [
      { action: 'setTaxCategory', key: 'taxCategory' },
      { action: 'setCustomerGroup', key: 'customerGroup' },
      { action: 'setSupplyChannel', key: 'supplyChannel' },
      { action: 'setProductType', key: 'productType' },
    ]

    t.test('should build reference actions', (t) => {
      const before = {
        taxCategory: { id: 'tc-1', typeId: 'tax-category' },
        customerGroup: undefined,
        supplyChannel: { id: 'sc-1', typeId: 'channel' },
        productType: {
          id: 'pt-1', typeId: 'product-type', obj: { id: 'pt-1' },
        },
      }
      const now = {
        // id changed
        taxCategory: { id: 'tc-2', typeId: 'tax-category' },
        // new ref
        customerGroup: { id: 'cg-1', typeId: 'customer-group' },
        // unset
        supplyChannel: null,
        // ignore update
        productType: {
          id: 'pt-1', typeId: 'product-type',
        },
      }

      const actions = buildReferenceActions({
        actions: testActions,
        diff: diffpatcher.diff(before, now),
        oldObj: before,
        newObj: now,
      })

      t.deepEqual(
        actions,
        [
          { action: 'setTaxCategory', taxCategory: now.taxCategory },
          { action: 'setCustomerGroup', customerGroup: now.customerGroup },
          { action: 'setSupplyChannel' },
        ],
        'build correct update actions'
      )

      t.end()
    })
  })
})
