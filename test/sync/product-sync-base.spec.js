import test from 'tape'
import clone from '../../src/sync/utils/clone'
import productsSyncFn, { actionGroups } from '../../src/sync/products'
import {
  baseActionsList,
  metaActionsList,
  referenceActionsList,
} from '../../src/sync/product-actions'

test('Sync::product::base', (t) => {
  let productsSync
  function setup () {
    productsSync = productsSyncFn()
  }

  t.test('should export action group list', (t) => {
    t.deepEqual(actionGroups, [
      'base',
      'meta',
      'references',
      'prices',
      'attributes',
      'images',
      'variants',
      'categories',
    ])
    t.end()
  })

  t.test('should define action lists', (t) => {
    t.deepEqual(
      baseActionsList,
      [
        { action: 'changeName', key: 'name' },
        { action: 'changeSlug', key: 'slug' },
        { action: 'setDescription', key: 'description' },
        { action: 'setSearchKeywords', key: 'searchKeywords' },
      ],
      'correctly define base actions list'
    )

    t.deepEqual(
      metaActionsList,
      [
        { action: 'setMetaTitle', key: 'metaTitle' },
        { action: 'setMetaDescription', key: 'metaDescription' },
        { action: 'setMetaKeywords', key: 'metaKeywords' },
      ],
      'correctly define base actions list'
    )

    t.deepEqual(
      referenceActionsList,
      [
        { action: 'setTaxCategory', key: 'taxCategory' },
      ],
      'correctly define reference actions list'
    )

    t.end()
  })

  t.test('should ensure given objects are not mutated', (t) => {
    setup()

    const before = {
      name: { en: 'Car', de: 'Auto' },
      masterVariant: {
        id: 1, sku: '001', attributes: [{ name: 'a1', value: 1 }] },
      variants: [
        { id: 2, sku: '002', attributes: [{ name: 'a2', value: 2 }] },
        { id: 3, sku: '003', attributes: [{ name: 'a3', value: 3 }] },
      ],
    }
    const now = {
      name: { en: 'Sport car' },
      masterVariant: {
        id: 1, sku: '100', attributes: [{ name: 'a1', value: 100 }] },
      variants: [
        { id: 2, sku: '200', attributes: [{ name: 'a2', value: 200 }] },
        { id: 3, sku: '300', attributes: [{ name: 'a3', value: 300 }] },
      ],
    }
    productsSync.buildActions(now, before)

    t.deepEqual(before, clone(before))
    t.deepEqual(now, clone(now))

    t.end()
  })

  t.test('should build `changeName` action', (t) => {
    setup()

    const before = { name: { en: 'Car', de: 'Auto' } }
    const now = { name: { en: 'Sport car' } }
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      Object.assign({ action: 'changeName' }, now),
    ])

    t.end()
  })

  t.test('should build `setSearchKeywords` action', (t) => {
    setup()

    /* eslint-disable max-len */
    const before = {
      searchKeywords: {
        en: [
          { text: 'Multi tool' },
          { text: 'Swiss Army Knife', suggestTokenizer: { type: 'whitespace' } },
        ],
        de: [
          { text: 'Schweizer Messer', suggestTokenizer: { type: 'custom', inputs: [ 'schweizer messer', 'offiziersmesser', 'sackmesser' ] } },
        ],
      },
    }
    const now = {
      searchKeywords: {
        en: [
          { text: 'Swiss Army Knife', suggestTokenizer: { type: 'whitespace' } },
        ],
        de: [
          { text: 'Schweizer Messer', suggestTokenizer: { type: 'custom', inputs: [ 'schweizer messer', 'offiziersmesser', 'sackmesser', 'messer' ] } },
        ],
        it: [
          { text: 'Coltello svizzero' },
        ],
      },
    }
    /* eslint-enable max-len */
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      Object.assign({ action: 'setSearchKeywords' }, now),
    ])

    t.end()
  })

  t.test('should build no actions if searchKeywords did not change', (t) => {
    setup()

    /* eslint-disable max-len */
    const before = {
      name: { en: 'Car', de: 'Auto' },
      searchKeywords: {
        en: [
          { text: 'Multi tool' },
          { text: 'Swiss Army Knife', suggestTokenizer: { type: 'whitespace' } },
        ],
        de: [
          { text: 'Schweizer Messer', suggestTokenizer: { type: 'custom', inputs: [ 'schweizer messer', 'offiziersmesser', 'sackmesser' ] } },
        ],
      },
    }
    /* eslint-enable max-len */
    const actions = productsSync.buildActions(before, before)
    t.deepEqual(actions, [])

    t.end()
  })

  t.test('should build `add/remove Category` actions', (t) => {
    setup()

    const before = {
      categories: [
        { id: 'aebe844e-0616-420a-8397-a22c48d5e99f' },
        { id: '34cae6ad-5898-4f94-973b-ae9ceb7464ce' },
      ],
    }
    const now = {
      categories: [
        { id: 'aebe844e-0616-420a-8397-a22c48d5e99f' },
        { id: '4f278964-48c0-4f2c-8b61-09310d1de60a' },
        { id: 'cca7a250-d8cf-4b8a-9d47-60fcc093b86b' },
      ],
    }
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      {
        action: 'removeFromCategory',
        category: { id: '34cae6ad-5898-4f94-973b-ae9ceb7464ce' },
      },
      {
        action: 'addToCategory',
        category: { id: '4f278964-48c0-4f2c-8b61-09310d1de60a' },
      },
      {
        action: 'addToCategory',
        category: { id: 'cca7a250-d8cf-4b8a-9d47-60fcc093b86b' },
      },
    ])
    t.end()
  })
})
