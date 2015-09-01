import expect from 'expect'
import credentials from '../../credentials'
import * as auth from '../../lib/utils/auth'
import * as headers from '../../lib/utils/headers'

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
          [headers.contentType]: headers.formMediaType,
          [headers.contentLength]: `${authRequest.body.length}`,
          [headers.userAgent]: headers.defaultUserAgent
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
