import test from 'tape'
import credentials from '../../../credentials'
import SphereClient from '../../../lib'

let count = 0
function uniqueId (prefix) {
  const id = `${prefix}${Date.now()}_${count}`
  count++
  return id
}

test('Integration - Client', t => {
  let client

  function setup () {
    client = SphereClient.create({
      auth: {
        credentials: {
          projectKey: credentials.project_key,
          clientId: credentials.client_id,
          clientSecret: credentials.client_secret,
        },
      },
      request: {
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'sphere-node-sdk',
        },
        maxParallel: 2,
      },
    })
  }

  t.test('::productTypes', t => {
    t.test('should create, update and delete a product type',
      { timeout: 5000 }
    , t => {
      setup()

      client.productTypes.create({
        name: 'My product type',
        description: 'My product type',
      })
      .then(({ body }) => client.productTypes.byId(body.id).update({
        version: body.version,
        actions: [{ action: 'changeName', name: 'Type foo' }],
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

    t.test('should expand productType on creation', { timeout: 5000 }, t => {
      setup()

      client.productTypes.create({
        name: uniqueId('shirts'), description: uniqueId('shirts'),
      })
      .then(({ body }) =>
        client.products.expand('productType').create({
          productType: {
            typeId: 'product-type',
            id: body.id,
          },
          name: { en: uniqueId('shirt') },
          slug: { en: uniqueId('shirt') },
        })
      )
      .then(({ body }) => {
        t.ok(body.productType.hasOwnProperty('obj'))
        const productType = body.productType.obj

        // Cleanup
        return client.products.byId(body.id).delete(body.version)
        .then(() => {
          const { id, version } = productType
          return client.productTypes.byId(id).delete(version)
        })
      })
      .then(() => t.end())
      .catch(t.end)
    })
  })
})
