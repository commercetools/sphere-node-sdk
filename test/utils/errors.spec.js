import expect from 'expect'
import * as errors from '../../lib/utils/errors'

const errorsMap = [
  { type: 'BadRequest', statusCode: 400 },
  { type: 'Unauthorized', statusCode: 401 },
  { type: 'NotFound', statusCode: 404 },
  { type: 'ConcurrentModification', statusCode: 409 },
  { type: 'InternalServerError', statusCode: 500 },
  { type: 'ServiceUnavailable', statusCode: 503 }
]

describe('Utils', () => {

  describe('::errors', () => {

    it('should export native errors', () => {
      expect(errors.nativeErrors).toExist()
    })

    it('should create general HttpError', () => {
      const e = new errors.HttpError('My bad', { statusCode: 500 })

      expect(e.message).toEqual('My bad')
      expect(e.statusCode).toBe(500)
      expect(e.code).toBe(500)
      expect(e.body).toEqual({ statusCode: 500 })
      expect(e).toBeAn(Error)
      expect(e).toBeAn(errors.HttpError)
    })

    errorsMap.forEach(error => {

      it(`should create ${error.type}`, () => {
        const expectedBody = { // Just to have an example of JSON response body
          statusCode: 409,
          message: 'Object e6490269-2733-4531-978d-316047e44a56 has a ' +
            'different version than expected. Expected: 1 - Actual: 2.',
          errors: [
            {
              statusCode: 'ConcurrentModification',
              message: 'Object e6490269-2733-4531-978d-316047e44a56 has a ' +
                'different version than expected. Expected: 1 - Actual: 2.'
            }
          ],
          originalRequest: {
            endpoint: '/inventory/e6490269-2733-4531-978d-316047e44a56',
            payload: {
              version: 1,
              actions: [
                { action: 'addQuantity', quantity: 10 }
              ]
            }
          }
        }

        const e = new errors[error.type]('Ooops', expectedBody)

        expect(e.message).toEqual('Ooops')
        expect(e.statusCode).toBe(error.statusCode)
        expect(e.code).toBe(error.statusCode)
        expect(e.body).toEqual(expectedBody)
        expect(e).toBeAn(Error)
        expect(e).toBeAn(errors[error.type])
      })
    })

  })
})
