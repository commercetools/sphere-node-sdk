import sinon from 'sinon'
import expect from 'expect'
import handleResponse, { errorsMap } from '../../lib/utils/handle-response'
import * as errors from '../../lib/utils/errors'

describe('Utils', () => {

  describe('::handleResponse', () => {

    let mockUtils, mockFetchJson, mockFetchText, mockDescription

    beforeEach(() => {
      mockUtils = { httpClient: () => {} }
      mockFetchJson = (ok, status, expectBody) => {
        return { ok, status,
          headers: {
            get: () => 'application/json',
            raw: () => ({ ['Content-Type']: 'application/json' })
          },
          json: () => Promise.resolve(expectBody)
        }
      }
      mockFetchText = (ok, status, expectBody) => {
        return { ok, status,
          headers: {
            get: () => 'text/html',
            raw: () => ({
              ['Content-Type']: 'text/html'
            })
          },
          text: () => Promise.resolve(expectBody)
        }
      }
      mockDescription = { url: '/foo', method: 'GET' }
    })

    it('should resolve response', done => {
      const stub = sinon.stub(mockUtils, 'httpClient', response => {
        return Promise.resolve(mockFetchJson(true, 200, { foo: 'bar' }))
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
        return Promise.resolve(mockFetchJson(false, 404))
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
    })

    it('should throw with unexpected error (non json)', done => {
      const stub = sinon.stub(mockUtils, 'httpClient', response => {
        return Promise.resolve(mockFetchText(false, 500, 'Oops, too bad!'))
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
          headers: { ['Content-Type']: 'text/html' }
        })
        done()
      })
    })

    Object.keys(errorsMap).forEach(code => {
      it(`should throw with a mapped error ${code}`, done => {
        const stub = sinon.stub(mockUtils, 'httpClient', response => {
          return Promise.resolve(
            mockFetchJson(false, parseInt(code), { message: 'Oops' }))
        })
        handleResponse(mockUtils.httpClient, mockDescription)
        .then(() => done('It should have failed'))
        .catch(error => {
          expect(error).toBeAn(errorsMap[code])
          expect(error.statusCode).toBe(parseInt(code))
          expect(error.message).toEqual('Oops')
          expect(error.body).toEqual({
            message: 'Oops',
            statusCode: code,
            originalRequest: mockDescription,
            headers: { ['Content-Type']: 'application/json' }
          })
          done()
        })
      })
    })

  })
})
