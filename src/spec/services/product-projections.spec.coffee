Q = require 'q'
ProductProjectionService = require '../../lib/services/product-projections'

###*
 * Describe service specific implementations
###
describe 'ProductProjectionService', ->

  beforeEach ->
    @restMock =
      config: {}
      GET: (endpoint, callback) ->
      POST: -> (endpoint, payload, callback) ->
      PUT: ->
      DELETE: ->
      _preRequest: ->
      _doRequest: ->
    @loggerMock =
      trace: ->
      debug: ->
      info: ->
      warn: ->
      error: ->
      fatal: ->

  afterEach ->
    @restMock = null
    @loggerMock = null

  it 'should query for staged', ->
    service = new ProductProjectionService @restMock, @loggerMock
    expect(service.staged()._queryString()).toBe 'limit=100&staged=true'
