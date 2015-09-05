import expect from 'expect'
import credentials from '../../credentials'
import * as auth from '../../lib/utils/auth'

const authRequest = auth.buildRequest({})

describe('Integration - Auth', () => {

  let options

  beforeEach(() => {
    options = {
      Promise: Promise,
      auth: {
        credentials: {
          projectKey: credentials.project_key,
          clientId: credentials.client_id,
          clientSecret: credentials.client_secret
        }
      },
      request: {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': Buffer.byteLength(authRequest.body),
          'User-Agent': 'sphere-node-sdk'
        },
        timeout: 20000
      }
    }
  })

  it('should request a new token', function (done) {
    this.timeout(5000)

    auth.getAccessToken(options)
    .then(({ body }) => {
      expect(body.access_token).toBeA('string')
      expect(body.access_token.length).toBeGreaterThan(0)
      done()
    })
    .catch(done)
  })

})
