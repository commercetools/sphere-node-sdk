import test from 'tape'
import sinon from 'sinon'
import handleResponse, { errorsMap } from '../../src/utils/handle-response'
import * as errors from '../../src/utils/errors'

test('Utils::handleResponse', t => {
  let mockUtils
  let mockFetch
  let mockDescription

  function setup () {
    mockUtils = { httpClient: () => {} }
    mockFetch = (ok, status, expectBody) => ({
      ok, status,
      headers: {
        raw: () => ({ 'Content-Type': 'application/json' }),
      },
      json: () => Promise.resolve(expectBody),
      text: () => Promise.resolve(expectBody),
    })
    mockDescription = { url: '/foo', method: 'GET' }
  }

  t.test('should resolve response', t => {
    setup()

    const stub = sinon.stub(mockUtils, 'httpClient', () =>
      Promise.resolve(mockFetch(true, 200, { foo: 'bar' }))
    )
    handleResponse(mockUtils.httpClient, mockDescription)
    .then(response => {
      t.true(stub.called)
      t.deepEqual(response, {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body: { foo: 'bar' },
      })
      t.end()
    })
    .catch(t.end)
  })

  t.test('should throw with status code 404', t => {
    setup()

    const stub = sinon.stub(mockUtils, 'httpClient', () =>
      Promise.resolve(mockFetch(false, 404))
    )
    handleResponse(mockUtils.httpClient, mockDescription)
    .then(() => t.end('It should have failed'))
    .catch(error => {
      t.true(stub.called)
      t.true(error instanceof errors.NotFound)
      t.equal(error.statusCode, 404)
      t.equal(error.message, 'Endpoint /foo not found.')
      t.deepEqual(error.body, {
        statusCode: 404,
        message: 'Endpoint /foo not found.',
        originalRequest: mockDescription,
        headers: { 'Content-Type': 'application/json' },
      })
      t.end()
    })
    .catch(t.end)
  })

  t.test('should throw with unexpected error (non json)', t => {
    setup()

    const stub = sinon.stub(mockUtils, 'httpClient', () =>
      Promise.resolve(mockFetch(false, 500, 'Oops, too bad!'))
    )
    handleResponse(mockUtils.httpClient, mockDescription)
    .then(() => t.end('It should have failed'))
    .catch(error => {
      t.true(stub.called)
      t.true(error instanceof errors.HttpError)
      t.equal(error.statusCode, 500)
      t.equal(error.message, 'Unexpected non-JSON error response.')
      t.deepEqual(error.body, {
        statusCode: 500,
        raw: 'Oops, too bad!',
        originalRequest: mockDescription,
        headers: { 'Content-Type': 'application/json' },
      })
      t.end()
    })
    .catch(t.end)
  })

  Object.keys(Object.assign({}, errorsMap, {
    511: errors.HttpError,
  })).forEach(code => {
    t.test(`should throw with a mapped error ${code}`, t => {
      setup()

      const stub = sinon.stub(mockUtils, 'httpClient', () =>
        Promise.resolve(mockFetch(false, parseInt(code, 10),
          JSON.stringify({ message: 'Oops' })))
      )
      handleResponse(mockUtils.httpClient, mockDescription)
      .then(() => t.end('It should have failed'))
      .catch(error => {
        t.true(stub.called)
        t.true(error instanceof (errorsMap[code] || errors.HttpError))
        t.equal(error.statusCode, parseInt(code, 10))
        t.equal(error.message,
          code === 499 ? 'Unknown error with code foo' : 'Oops')
        t.deepEqual(error.body, {
          message: 'Oops',
          statusCode: parseInt(code, 10),
          originalRequest: mockDescription,
          headers: { 'Content-Type': 'application/json' },
        })
        t.end()
      })
      .catch(t.end)
    })
  })
})
