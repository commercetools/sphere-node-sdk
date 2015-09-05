import expect from 'expect'
import credentials from '../../../credentials'
import SphereClient from '../../../lib'

describe('Integration - Client', () => {

  let client

  beforeEach(() => {
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
  })

  describe('::productTypes', () => {

    it('should create, update and delete a product type', function (done) {
      this.timeout(5000)

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
        expect(body.name).toEqual('Type foo')
        expect(body.version).toBe(2)
        return client.productTypes.byId(body.id).delete(body.version)
      })
      .then(({ statusCode }) => {
        expect(statusCode).toBe(200)
        done()
      })
      .catch(done)
    })

  })

  describe('::products', () => {

    it('should get some products', function (done) {
      this.timeout(5000)

      Promise.all(Array.apply(null, Array(10))
        .map(() => client.productProjections.fetch()))
      .then(allJsonRes => {
        allJsonRes.forEach(({ body }) => {
          expect(body.results).toExist()
        })
        done()
      })
      .catch(done)
    })

  })
})
