import test from 'tape'
import SphereClient from '../../lib'

test('SphereClient', t => {
  let client

  function setup () {
    client = new SphereClient({})
  }

  t.test('::graphql', t => {
    t.test('should have specific verbs', t => {
      setup()

      t.true(client.graphql.hasOwnProperty('query'))

      t.false(client.graphql.hasOwnProperty('fetch'))
      t.false(client.graphql.hasOwnProperty('create'))
      t.false(client.graphql.hasOwnProperty('update'))
      t.false(client.graphql.hasOwnProperty('delete'))
      t.end()
    })
  })
})
