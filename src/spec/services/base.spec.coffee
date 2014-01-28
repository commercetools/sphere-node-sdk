Q = require('q')
BaseService = require('../../lib/services/base')

describe 'BaseService', ->

  ID = "1234-abcd-5678-efgh"

  beforeEach ->
    @restMock =
      config: {}
      GET: (endpoint, callback)->
      POST: ->
      PUT: ->
      DELETE: ->
      _preRequest: ->
      _doRequest: ->
    @base = new BaseService @restMock

  afterEach ->
    @base = null
    @restMock = null

  it 'should have constants defined', ->
    expect(BaseService.baseResourceEndpoint).toBe ''

  it 'should not share variables between instances', ->
    base1 = new BaseService @restMock
    base1._currentEndpoint = '/foo/1'
    base2 = new BaseService @restMock
    expect(base2._currentEndpoint).toBe ''

  it 'should initialize with Rest client', ->
    expect(@base).toBeDefined()
    expect(@base._currentEndpoint).toBe ''

  it 'should return promise on fetch', ->
    promise = @base.fetch()
    expect(Q.isPromise(promise)).toBe true

  it 'should resolve the promise on fetch', (done)->
    spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback(null, {statusCode: 200}, '{"foo": "bar"}'))
    @base.fetch().then (result)->
      expect(result).toEqual foo: 'bar'
      done()

  it 'should reject the promise on fetch', (done)->
    spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback('foo', null, null))
    @base.fetch().then (result)->
      expect(result).not.toBeDefined()
    .fail (e)->
      expect(e).toBe 'foo'
      done()

  it 'should build endpoint with id', ->
    @base.byId(ID)
    expect(@base._currentEndpoint).toBe "/#{ID}"

  it 'should chain "byId"', ->
    clazz = @base.byId(ID)
    expect(clazz).toEqual @base

    promise = @base.byId(ID).fetch()
    expect(Q.isPromise(promise)).toBe true
