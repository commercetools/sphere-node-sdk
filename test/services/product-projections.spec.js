import test from 'tape'
import SphereClient from '../../src'

test('SphereClient', t => {
  let client

  function setup () {
    client = new SphereClient({})
  }

  t.test('::product-projections', t => {
    t.test('should have read-only verbs', t => {
      setup()

      t.true(client.productProjections.hasOwnProperty('fetch'))
      t.false(client.productProjections.hasOwnProperty('create'))
      t.false(client.productProjections.hasOwnProperty('update'))
      t.false(client.productProjections.hasOwnProperty('delete'))
      t.end()
    })
  })
})
