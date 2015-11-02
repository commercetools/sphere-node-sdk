import test from 'tape'
import ProductSync from '../../lib/sync/product-sync'

test('Sync::product', t => {

  let sync
  function setup () {
    sync = new ProductSync()
  }

  t.test('should build `changeName` action', t => {
    setup()

    sync.buildActions(
      { name: { en: 'Car' }, variants: [] },
      { name: { en: 'Auto' }, variants: [] }
    )

    t.equal(sync.shouldUpdate(), true)
    t.deepEqual(sync.getUpdateActions(), [
      { action: 'changeName', name: { en: 'Car' } }
    ])
    t.end()
  })
})
