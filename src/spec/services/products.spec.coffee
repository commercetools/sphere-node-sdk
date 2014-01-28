ProductService = require('../../lib/services/products')

describe 'ProductService', ->

  beforeEach ->
    @restMock =
      config: {}
      GET: ->
      POST: ->
      PUT: ->
      DELETE: ->
      _preRequest: ->
      _doRequest: ->

  afterEach ->
    @restMock = null

  it 'should have constants defined', ->
    expect(ProductService.baseResourceEndpoint).toBe '/products'

  it 'should initialize with Rest client', ->
    products = new ProductService @restMock
    expect(products).toBeDefined()
    expect(products._currentEndpoint).toBe '/products'
