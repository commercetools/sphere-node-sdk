import test from 'tape'
import * as errors from '../../lib/utils/errors'

const errorsMap = [
  { type: 'BadRequest', statusCode: 400 },
  { type: 'Unauthorized', statusCode: 401 },
  { type: 'NotFound', statusCode: 404 },
  { type: 'ConcurrentModification', statusCode: 409 },
  { type: 'InternalServerError', statusCode: 500 },
  { type: 'ServiceUnavailable', statusCode: 503 }
]

test('Utils::errors', t => {

  t.test('should export native errors', t => {
    t.ok(errors.nativeErrors)
    t.end()
  })

  t.test('should create general HttpError', t => {
    const e = new errors.HttpError('My bad', { statusCode: 500 })

    t.equal(e.message, 'My bad')
    t.equal(e.statusCode, 500)
    t.equal(e.code, 500)
    t.deepEqual(e.body, { statusCode: 500 })
    t.true(e instanceof Error)
    t.true(e instanceof errors.HttpError)
    t.end()
  })

  errorsMap.forEach(error => {

    t.test(`should create ${error.type}`, t => {
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

      t.equal(e.message, 'Ooops')
      t.equal(e.statusCode, error.statusCode)
      t.equal(e.code, error.statusCode)
      t.equal(e.body, expectedBody)
      t.true(e instanceof Error)
      t.true(e instanceof errors[error.type])
      t.end()
    })
  })

})
