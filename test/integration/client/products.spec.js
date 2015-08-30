import expect from 'expect'
import { SphereClient } from '../../../lib'
import credentials from '../../../config'

describe('Integration - Client', () => {

  describe('::products', () => {

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
            'Content-Type': 'application/json'
          },
          maxParallel: 2
        }
      })
    })

    it('should get some products', function (done) {
      this.timeout(5000)

      Promise.all(Array.apply(null, Array(10))
        .map(() => client.productProjections.fetch()))
      .then(allRes => Promise.all(allRes.map(res => res.json())))
      .then(allJsonRes => {
        allJsonRes.forEach(res => {
          expect(res.results).toExist()
        })
        done()
      })
      .catch(done)
    })
  })
})
