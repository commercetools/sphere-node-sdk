import { expect } from 'chai'
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
          }
        }
      })
    })

    it('should get some products', done => {
      client.productProjections.fetch()
        .then(res => res.json())
        .then(res => {
          expect(res.total).to.equal(0)
          done()
        })
        .catch(done)
    })
  })
})
