Q = require('q')
ProductService = require('../../lib/services/products')

describe 'ProductService', ->

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
    @products = new ProductService @restMock

  afterEach ->
    @products = null
    @restMock = null

  it 'should have constants defined', ->
    expect(ProductService.baseResourceEndpoint).toBe '/products'

  it 'should initialize with Rest client', ->
    expect(@products).toBeDefined()
    expect(@products._currentEndpoint).toBe '/products'

  it 'should return promise on fetch', ->
    promise = @products.fetch()
    expect(Q.isPromise(promise)).toBe true

  it 'should resolve the promise on fetch', (done)->
    spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback(null, {statusCode: 200}, '{"foo": "bar"}'))
    @products.fetch().then (result)->
      expect(result).toEqual foo: 'bar'
      done()

  it 'should reject the promise on fetch', (done)->
    spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback('foo', null, null))
    @products.fetch().then (result)->
      expect(result).not.toBeDefined()
    .fail (e)->
      expect(e).toBe 'foo'
      done()

  it 'should build endpoint with id', ->
    @products.byId(ID)
    expect(@products._currentEndpoint).toBe "/products/#{ID}"

  it 'should chain "byId"', ->
    clazz = @products.byId(ID)
    expect(clazz).toEqual @products

    promise = @products.byId(ID).fetch()
    expect(Q.isPromise(promise)).toBe true
