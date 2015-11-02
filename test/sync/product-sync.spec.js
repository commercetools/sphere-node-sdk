import test from 'tape'
import * as sync from '../../lib/sync'

test('Sync::product', t => {

  let productSync
  function setup () {
    productSync = sync.products()
  }

  t.test('should build `changeName` action', t => {
    setup()

    productSync.buildActions(
      { name: { en: 'Car' }, variants: [] },
      { name: { en: 'Auto' }, variants: [] }
    )

    t.equal(productSync.shouldUpdate(), true)
    t.deepEqual(productSync.getUpdateActions(), [
      { action: 'changeName', name: { en: 'Car' } }
    ])
    t.end()
  })

  t.test('should build `add/remove Category` actions', t => {
    setup()

    productSync.buildActions(
      {
        categories: [
          { id: 'aebe844e-0616-420a-8397-a22c48d5e99f' },
          { id: '4f278964-48c0-4f2c-8b61-09310d1de60a' } ,
          { id: 'cca7a250-d8cf-4b8a-9d47-60fcc093b86b' }
        ]
      },
      {
        categories: [
          { id: 'aebe844e-0616-420a-8397-a22c48d5e99f' },
          { id: '34cae6ad-5898-4f94-973b-ae9ceb7464ce' }
        ]
      }
    )

    t.equal(productSync.shouldUpdate(), true)
    t.deepEqual(productSync.getUpdateActions(), [
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
