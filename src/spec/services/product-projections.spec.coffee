Q = require 'q'
ProductProjectionService = require '../../lib/services/product-projections'

###*
 * Describe service specific implementations
###
describe 'ProductProjectionService', ->

  beforeEach ->
    @loggerMock =
      trace: ->
      debug: ->
      info: ->
      warn: ->
      error: ->
      fatal: ->
    @service = new ProductProjectionService null, @loggerMock

  it 'should query for staged', ->
    expect(@service.staged()._queryString()).toBe 'limit=100&staged=true'
