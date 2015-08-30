import expect from 'expect'
import * as auth from '../../lib/utils/auth'
import credentials from '../../config'

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
          'Content-Length': `${authRequest.body.length}`,
          'User-Agent': 'sphere-node-sdk.2.0'
        },
        timeout: 20000
      }
    }
  })

  it('should request a new token', done => {
    auth.getAccessToken(options)
    .then(({ body }) => {
      expect(body.access_token).toBeA('string')
      expect(body.access_token.length).toBeGreaterThan(0)
      done()
    })
    .catch(done)
  })

})
