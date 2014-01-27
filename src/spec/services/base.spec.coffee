Q = require('q')
BaseService = require('../../lib/services/base')

describe 'BaseService', ->

  beforeEach ->
    @restMock =
      config: {}
      GET: (endpoint, callback)->
      POST: ->
      PUT: ->
      DELETE: ->
      _preRequest: ->
      _doRequest: ->

  afterEach ->
    @restMock = null

  it 'should initialize with Rest client', ->
    base = new BaseService @restMock
    expect(base).toBeDefined()
    expect(base._projectEndpoint).toBe '/'

  it 'should return promise on fetch', ->
    base = new BaseService @restMock
    promise = base.fetch()
    expect(Q.isPromise(promise)).toBe true

  it 'should resolve the promise on fetch', (done)->
    spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback(null, {statusCode: 200}, '{"foo": "bar"}'))
    base = new BaseService @restMock
    base.fetch().then (result)->
      expect(result).toEqual foo: 'bar'
      done()

  it 'should reject the promise on fetch', (done)->
    spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback('foo', null, null))
    base = new BaseService @restMock
    base.fetch().then (result)->
      expect(result).not.toBeDefined()
    .fail (e)->
      expect(e).toBe 'foo'
      done()
