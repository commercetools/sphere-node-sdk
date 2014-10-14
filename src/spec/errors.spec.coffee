_ = require 'underscore'
{Errors} = require '../lib/main'

ERRORS = [
  {name: 'BadRequest', code: 400}
  {name: 'NotFound', code: 404}
  {name: 'ConcurrentModification', code: 409}
  {name: 'InternalServerError', code: 500}
  {name: 'ServiceUnavailable', code: 503}
]

describe 'Errors', ->

  it 'should create general error', ->
    e = new Errors.SphereError 'My bad'

    expect(e.message).toBe 'My bad'
    expect(e.code).not.toBeDefined()
    expect(e.body).not.toBeDefined()
    expect(e instanceof Error).toBe true
    expect(e instanceof Errors.SphereError).toBe true

  _.each ERRORS, (error) ->
    it "should create #{error.name} error", ->
      expectedBody = # just to have an example of JSON response body
        statusCode: 409
        message: 'Object e6490269-2733-4531-978d-316047e44a56 has a different version than expected. Expected: 1 - Actual: 2.'
        errors: [
          {
            code: 'ConcurrentModification',
            message: 'Object e6490269-2733-4531-978d-316047e44a56 has a different version than expected. Expected: 1 - Actual: 2.'
          }
        ]
        originalRequest:
          endpoint: '/inventory/e6490269-2733-4531-978d-316047e44a56'
          payload:
            version: 1
            actions: [
              {action: 'addQuantity', quantity: 10 }
            ]
      ce = new Errors.SphereHttpError[error.name] 'Ooops', expectedBody

      expect(ce.message).toBe 'Ooops'
      expect(ce.code).toBe error.code
      expect(ce.body).toBeDefined()
      expect(ce.body).toEqual expectedBody
      expect(ce instanceof Error).toBe true
      expect(ce instanceof Errors.SphereError).toBe true
      expect(ce instanceof Errors.SphereHttpError[error.name]).toBe true
