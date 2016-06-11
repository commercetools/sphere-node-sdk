import test from 'tape'
import credentials from '../../credentials'
import * as auth from '../../lib/utils/auth'

const authRequest = auth.buildRequest({
  credentials: {
    projectKey: credentials.project_key,
    clientId: credentials.client_id,
    clientSecret: credentials.client_secret,
  },
  host: 'auth.sphere.io',
})

test('Integration - Auth', t => {
  let options

  function setup () {
    options = {
      Promise: Promise, // eslint-disable-line object-shorthand
      auth: {
        credentials: {
          projectKey: credentials.project_key,
          clientId: credentials.client_id,
          clientSecret: credentials.client_secret,
        },
        host: 'auth.sphere.io',
      },
      request: {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': Buffer.byteLength(authRequest.body),
          'User-Agent': 'sphere-node-sdk',
        },
        timeout: 20000,
      },
    }
  }

  t.test('should request a new token', { timeout: 5000 }, t => {
    setup()

    auth.getAccessToken(options)
    .then(({ body }) => {
      t.equal(typeof body.access_token, 'string')
      t.ok(body.access_token.length > 0)
      t.end()
    })
    .catch(t.end)
  })
})
