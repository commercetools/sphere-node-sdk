import test from 'tape'
import credentials from '../../../credentials'
import SphereClient from '../../../lib'

test('Integration - Client', t => {

  let client

  function setup () {
    client = SphereClient.create({
      auth: {
        credentials: {
          projectKey: credentials.project_key,
          clientId: credentials.client_id,
          clientSecret: credentials.client_secret
        }
      },
      request: {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'sphere-node-sdk'
        },
        maxParallel: 2
      }
    })
  }

  t.test('::productTypes', t => {

    t.test('should create, update and delete a product type',
      { timeout: 5000 }
    , t => {
      setup()

      client.productTypes.create({
        name: 'My product type',
        description: 'My product type'
      })
      .then(({ body }) => client.productTypes.byId(body.id).update({
        version: body.version,
        actions: [{ action: 'changeName', name: 'Type foo' }]
      }))
      .then(({ body }) => client.productTypes.byId(body.id).fetch())
      .then(({ body }) => {
        t.equal(body.name, 'Type foo')
        t.equal(body.version, 2)
        return client.productTypes.byId(body.id).delete(body.version)
      })
      .then(({ statusCode }) => {
        t.equal(statusCode, 200)
        t.end()
      })
      .catch(t.end)
    })

  })

  t.test('::products', t => {

    t.test('should get some products', { timeout: 5000 }, t => {
      setup()

      Promise.all(Array.apply(null, Array(10))
        .map(() => client.productProjections.fetch()))
      .then(allJsonRes => {
        allJsonRes.forEach(({ body }) => {
          t.ok(body.results, 'body `results` exist')
        })
        t.end()
      })
      .catch(t.end)
    })

  })
})
