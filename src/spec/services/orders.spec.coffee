Q = require 'q'
{TaskQueue} = require 'sphere-node-utils'
OrderService = require '../../lib/services/orders'

###*
 * Describe service specific implementations
###
describe 'OrderService', ->

  beforeEach ->
    @restMock =
      config: {}
      GET: (endpoint, callback) ->
      POST: -> (endpoint, payload, callback) ->
      PUT: ->
      DELETE: -> (endpoint, callback) ->
      PAGED: -> (endpoint, callback, notify) ->
      _preRequest: ->
      _doRequest: ->
    @loggerMock =
      trace: ->
      debug: ->
      info: ->
      warn: ->
      error: ->
      fatal: ->
    @task = new TaskQueue
    @service = new OrderService
      _rest: @restMock
      _task: @task
      _logger: @loggerMock
      _stats:
        includeHeaders: false

  it 'should send request for import endpoint', ->
    spyOn(@restMock, 'POST')
    @service.import({foo: 'bar'})
    expect(@restMock.POST).toHaveBeenCalledWith '/orders/import', {foo: 'bar'}, jasmine.any(Function)
