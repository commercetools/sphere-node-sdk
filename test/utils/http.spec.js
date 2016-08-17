import test from 'tape'
import sinon from 'sinon'
import httpFn from '../../src/utils/http'

test('Utils::http', t => {
  t.test('should expose a function', t => {
    const http = httpFn({
      Promise: () => {},
      request: {},
    })
    t.equal(typeof http, 'function')
    t.end()
  })

  t.test('should pass a httpMock for testing', t => {
    const spy = sinon.spy()
    const http = httpFn({
      Promise: Promise, // eslint-disable-line object-shorthand
      auth: {
        credentials: {},
        shouldRetrieveToken: cb => { cb(true) },
      },
      request: {
        agent: null,
        headers: { 'User-Agent': 'sphere-node-sdk' },
        timeout: 20000,
        urlPrefix: null,
      },
      httpMock: spy,
    })

    http('http://api.sphere.io/foo/bar', {
      method: 'POST',
      body: JSON.stringify({ foo: 'bar' }),
      headers: { Authorization: 'supersecret' },
    })

    t.equal(spy.getCall(0).args[0], 'http://api.sphere.io/foo/bar')
    t.deepEqual(spy.getCall(0).args[1], {
      agent: null,
      method: 'POST',
      body: JSON.stringify({ foo: 'bar' }),
      headers: {
        Authorization: 'supersecret',
        'Content-Length': 13,
        'User-Agent': 'sphere-node-sdk',
      },
      timeout: 20000,
    })
    t.end()
  })
})
