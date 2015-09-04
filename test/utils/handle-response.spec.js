import sinon from 'sinon'
import expect from 'expect'
import handleResponse, { errorsMap } from '../../lib/utils/handle-response'
import * as errors from '../../lib/utils/errors'

describe('Utils', () => {

  describe('::handleResponse', () => {

    let mockUtils, mockFetch, mockDescription

    beforeEach(() => {
      mockUtils = { httpClient: () => {} }
      mockFetch = (ok, status, expectBody) => {
        return { ok, status,
          headers: {
            raw: () => ({ ['Content-Type']: 'application/json' })
          },
          json: () => Promise.resolve(expectBody),
          text: () => Promise.resolve(expectBody)
        }
      }
      mockDescription = { url: '/foo', method: 'GET' }
    })

    it('should resolve response', done => {
      const stub = sinon.stub(mockUtils, 'httpClient', response => {
        return Promise.resolve(mockFetch(true, 200, { foo: 'bar' }))
      })
      handleResponse(mockUtils.httpClient, mockDescription)
      .then(response => {
        expect(response).toEqual({
          statusCode: 200,
          headers: { ['Content-Type']: 'application/json' },
          body: { foo: 'bar' }
        })
        done()
      })
      .catch(done)
    })

    it('should throw with status code 404', done => {
      const stub = sinon.stub(mockUtils, 'httpClient', response => {
        return Promise.resolve(mockFetch(false, 404))
      })
      handleResponse(mockUtils.httpClient, mockDescription)
      .then(() => done('It should have failed'))
      .catch(error => {
        expect(error).toBeAn(errors.NotFound)
        expect(error.statusCode).toBe(404)
        expect(error.message).toEqual('Endpoint /foo not found.')
        expect(error.body).toEqual({
          statusCode: 404,
          message: 'Endpoint /foo not found.',
          originalRequest: mockDescription,
          headers: { ['Content-Type']: 'application/json' }
        })
        done()
      })
      .catch(done)
    })

    it('should throw with unexpected error (non json)', done => {
      const stub = sinon.stub(mockUtils, 'httpClient', response => {
        return Promise.resolve(mockFetch(false, 500, 'Oops, too bad!'))
      })
      handleResponse(mockUtils.httpClient, mockDescription)
      .then(() => done('It should have failed'))
      .catch(error => {
        expect(error).toBeAn(errors.HttpError)
        expect(error.statusCode).toBe(500)
        expect(error.message).toEqual('Unexpected non-JSON error response.')
        expect(error.body).toEqual({
          statusCode: 500,
          message: 'Oops, too bad!',
          originalRequest: mockDescription,
          headers: { ['Content-Type']: 'application/json' }
        })
        done()
      })
      .catch(done)
    })

    Object.keys(Object.assign({}, errorsMap, {
      511: errors.HttpError
    })).forEach(code => {
      it(`should throw with a mapped error ${code}`, done => {
        const stub = sinon.stub(mockUtils, 'httpClient', response => {
          return Promise.resolve(
            mockFetch(false, parseInt(code), JSON.stringify({ message: 'Oops' })))
        })
        handleResponse(mockUtils.httpClient, mockDescription)
        .then(() => done('It should have failed'))
        .catch(error => {
          expect(error).toBeAn(errorsMap[code] || errors.HttpError)
          expect(error.statusCode).toBe(parseInt(code))
          expect(error.message).toEqual(
            code === 499 ? 'Unknown error with code foo' : 'Oops')
          expect(error.body).toEqual({
            message: 'Oops',
            statusCode: code,
            originalRequest: mockDescription,
            headers: { ['Content-Type']: 'application/json' }
          })
          done()
        })
        .catch(done)
      })
    })

  })
})
