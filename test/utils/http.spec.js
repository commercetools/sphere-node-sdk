import sinon from 'sinon'
import expect from 'expect'
import httpFn from '../../lib/utils/http'

describe('Utils', () => {

  describe('::http', () => {

    it('should expose a function', () => {
      const http = httpFn({
        Promise: () => {},
        request: {}
      })
      expect(http).toBeA('function')
    })

    it('should pass a httpMock for testing', () => {
      const spy = sinon.spy()
      const http = httpFn({
        Promise: Promise,
        auth: {
          credentials: {},
          shouldRetrieveToken: cb => { cb(true) }
        },
        request: {
          agent: null,
          headers: { 'User-Agent': 'sphere-node-sdk' },
          timeout: 20000,
          urlPrefix: null
        },
        httpMock: spy
      })

      http('http://api.sphere.io/foo/bar', {
        method: 'POST',
        body: JSON.stringify({ foo: 'bar' }),
        headers: { 'Authorization': 'supersecret' }
      })

      expect(spy.getCall(0).args[0]).toEqual('http://api.sphere.io/foo/bar')
      expect(spy.getCall(0).args[1]).toEqual({
        agent: null,
        method: 'POST',
        body: JSON.stringify({ foo: 'bar' }),
        headers: {
          'Authorization': 'supersecret',
          'Content-Length': 13,
          'User-Agent': 'sphere-node-sdk'
        },
        timeout: 20000
      })
    })
  })
})
