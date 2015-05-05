import { expect } from 'chai'
import * as auth from '../../lib/utils/auth'
import http from '../../lib/utils/http'
import credentials from '../../config'

const authRequest = auth.buildRequest({
  projectKey: credentials.project_key,
  clientId: credentials.client_id,
  clientSecret: credentials.client_secret
})

describe('Integration - Auth', () => {

  let httpFetch

  beforeEach(() => {
    httpFetch = http({
      Promise: Promise,
      auth: {},
      request: {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': `${authRequest.body.length}`
        },
        timeout: 20000
      }
    })
  })

  it('should request a new token', done => {
    httpFetch.post(authRequest.endpoint, authRequest.body)
      .then(res => res.json())
      .then(res => {
        expect(res.access_token).to.be.a('string')
          .and.to.have.length.above(0)
        done()
      })
      .catch(done)
  })

})
