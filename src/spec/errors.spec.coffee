_ = require 'underscore'
Promise = require 'bluebird'
{Errors} = require '../lib/main'

ERRORS = [
  {name: 'BadRequest', statusCode: 400}
  {name: 'Unauthorized', statusCode: 401}
  {name: 'NotFound', statusCode: 404}
  {name: 'MethodNotAllowed', statusCode: 405}
  {name: 'ConcurrentModification', statusCode: 409}
  {name: 'InternalServerError', statusCode: 500}
  {name: 'ServiceUnavailable', statusCode: 503}
]

describe 'Errors', ->

  it 'should create general HttpError', ->
    e = new Errors.HttpError 'My bad', {statusCode: 500}

    expect(e.message).toBe 'My bad'
    expect(e.statusCode).toBe 500
    expect(e.body).toEqual statusCode: 500
    expect(e instanceof Error).toBe true
    expect(e instanceof Errors.HttpError).toBe true

  it 'should create general SphereError', ->
    e = new Errors.SphereError 'My bad'

    expect(e.message).toBe 'My bad'
    expect(e.statusCode).not.toBeDefined()
    expect(e.body).toEqual {}
    expect(e instanceof Error).toBe true
    expect(e instanceof Errors.SphereError).toBe true

  it 'should create general GraphQLError', ->
    e = new Errors.GraphQLError 'My bad', {statusCode: 400}

    expect(e.message).toBe 'My bad'
    expect(e.statusCode).toBe 400
    expect(e.body).toEqual statusCode: 400
    expect(e instanceof Error).toBe true
    expect(e instanceof Errors.GraphQLError).toBe true

  _.each ERRORS, (error) ->
    it "should create #{error.name} error", ->
      expectedBody = # just to have an example of JSON response body
        statusCode: 409
        message: 'Object e6490269-2733-4531-978d-316047e44a56 has a different version than expected. Expected: 1 - Actual: 2.'
        errors: [
          {
            statusCode: 'ConcurrentModification',
            message: 'Object e6490269-2733-4531-978d-316047e44a56 has a different version than expected. Expected: 1 - Actual: 2.'
          }
        ]
        originalRequest:
          endpoint: '/inventory/e6490269-2733-4531-978d-316047e44a56'
          payload:
            version: 1
            actions: [
              {action: 'changeQuantity', quantity: 10 }
            ]
      ce = new Errors.SphereHttpError[error.name] 'Ooops', expectedBody

      expect(ce.message).toBe 'Ooops'
      expect(ce.statusCode).toBe error.statusCode
      expect(ce.body).toBeDefined()
      expect(ce.body).toEqual expectedBody
      expect(ce instanceof Error).toBe true
      expect(ce instanceof Errors.SphereError).toBe true
      expect(ce instanceof Errors.SphereHttpError[error.name]).toBe true

    it "should use #{error.name} constructor for pattern matching", (done) ->
      ce = new Errors.SphereHttpError[error.name] 'Ooops'
      r = ->
        new Promise (resolve, reject) ->
          setTimeout ->
            reject ce
          , 100
      r().then -> done 'It should have been rejected'
      .catch Errors.SphereHttpError[error.name], (e) ->
        expect(e.message).toBe 'Ooops'
        done()
      .catch (e) -> done 'It should have caught the exception before'
      .done()
