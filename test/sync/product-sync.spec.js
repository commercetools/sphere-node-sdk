import test from 'tape'
import productsSyncFn, { actionGroups } from '../../lib/sync/products'

test('Sync::product', t => {

  let productsSync
  function setup () {
    productsSync = productsSyncFn()
  }

  t.test('should export action group list', t => {
    t.deepEqual(actionGroups, [
      'base', 'references', 'prices', 'attributes',
      'images', 'variants', 'categories'
    ])
    t.end()
  })

  t.test('should ensure given objects are not mutated', t => {
    setup()

    const before = { name: { en: 'Car', de: 'Auto' } }
    const now = { name: { en: 'Sport car' } }
    productsSync.buildActions(now, before)

    t.deepEqual(before, { name: { en: 'Car', de: 'Auto' } })
    t.deepEqual(now, { name: { en: 'Sport car' } })
    t.end()
  })

  t.test('should build `changeName` action', t => {
    setup()

    const before = { name: { en: 'Car', de: 'Auto' } }
    const now = { name: { en: 'Sport car' } }
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      Object.assign({ action: 'changeName' }, now)
    ])
    t.end()
  })

  t.test('should not build `changeName` action if field is null', t => {
    setup()

    t.deepEqual(productsSync.buildActions({ name: null }, {}), [])
    t.deepEqual(productsSync.buildActions({}, { name: null }), [])
    t.end()
  })

  t.test('should build `changeSlug` action', t => {
    setup()

    const before1 = { slug: { en: 'sport-car' } }
    const now1 = { slug: { de: 'auto' } }
    const actions1 = productsSync.buildActions(now1, before1)
    t.deepEqual(actions1, [
      Object.assign({ action: 'changeSlug' }, now1)
    ])

    const before2 = {}
    const now2 = { slug: { de: 'auto' } }
    const actions2 = productsSync.buildActions(now2, before2)
    t.deepEqual(actions2, [
      Object.assign({ action: 'changeSlug' }, now2)
    ])

    const before3 = { slug: { de: 'auto' } }
    const now3 = {}
    const actions3 = productsSync.buildActions(now3, before3)
    t.deepEqual(actions3, [])

    const before4 = { slug: { de: 'auto' } }
    const now4 = { slug: null }
    const actions4 = productsSync.buildActions(now4, before4)
    t.deepEqual(actions4, [{ action: 'changeSlug' }])

    t.end()
  })

  t.test('should build `setDescription` action', t => {
    setup()

    const before = { description: { it: 'Una bella macchina' } }
    const now = { description: { en: 'A nice car', de: 'Ein schönes Auto' } }
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      Object.assign({ action: 'setDescription' }, now)
    ])
    t.end()
  })

  t.test('should build `setSearchKeywords` action', t => {
    setup()

    /* eslint-disable max-len */
    const before = {
      searchKeywords: {
        en: [
          { text: 'Multi tool' },
          { text: 'Swiss Army Knife', suggestTokenizer: { type: 'whitespace' } }
        ],
        de: [
          { text: 'Schweizer Messer', suggestTokenizer: { type: 'custom', inputs: [ 'schweizer messer', 'offiziersmesser', 'sackmesser' ] } }
        ]
      }
    }
    const now = {
      searchKeywords: {
        en: [
          { text: 'Swiss Army Knife', suggestTokenizer: { type: 'whitespace' } }
        ],
        de: [
          { text: 'Schweizer Messer', suggestTokenizer: { type: 'custom', inputs: [ 'schweizer messer', 'offiziersmesser', 'sackmesser', 'messer' ] } }
        ],
        it: [
          { text: 'Coltello svizzero' }
        ]
      }
    }
    /* eslint-enable max-len */
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      Object.assign({ action: 'setSearchKeywords' }, now)
    ])
    t.end()
  })

  t.test('should build no actions if searchKeywords did not change', t => {
    setup()

    /* eslint-disable max-len */
    const before = {
      name: { en: 'Car', de: 'Auto' },
      searchKeywords: {
        en: [
          { text: 'Multi tool' },
          { text: 'Swiss Army Knife', suggestTokenizer: { type: 'whitespace' } }
        ],
        de: [
          { text: 'Schweizer Messer', suggestTokenizer: { type: 'custom', inputs: [ 'schweizer messer', 'offiziersmesser', 'sackmesser' ] } }
        ]
      }
    }
    /* eslint-enable max-len */
    const actions = productsSync.buildActions(before, before)

    t.deepEqual(actions, [])
    t.end()
  })

  t.test('should build `setTaxCategory` action', t => {
    setup()

    const before = { taxCategory: { typeId: 'tax-category', id: '123' } }
    const now = { taxCategory: { typeId: 'tax-category', id: '456' } }
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      Object.assign({ action: 'setTaxCategory' }, now)
    ])
    t.end()
  })

  t.test('should build `add/remove Category` actions', t => {
    setup()

    const before = {
      categories: [
        { id: 'aebe844e-0616-420a-8397-a22c48d5e99f' },
        { id: '34cae6ad-5898-4f94-973b-ae9ceb7464ce' }
      ]
    }
    const now = {
      categories: [
        { id: 'aebe844e-0616-420a-8397-a22c48d5e99f' },
        { id: '4f278964-48c0-4f2c-8b61-09310d1de60a' } ,
        { id: 'cca7a250-d8cf-4b8a-9d47-60fcc093b86b' }
      ]
    }
    const actions = productsSync.buildActions(now, before)

    t.deepEqual(actions, [
      {
        action: 'removeFromCategory',
        category: { id: '34cae6ad-5898-4f94-973b-ae9ceb7464ce' }
      },
      {
        action: 'addToCategory',
        category: { id: '4f278964-48c0-4f2c-8b61-09310d1de60a' }
      },
      {
        action: 'addToCategory',
        category: { id: 'cca7a250-d8cf-4b8a-9d47-60fcc093b86b' }
      }
    ])
    t.end()
  })
})
