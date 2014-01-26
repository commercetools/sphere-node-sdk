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

  it 'should initialize with Rest client', ->
    products = new ProductService @restMock
    expect(products).toBeDefined()
    expect(products._projectEndpoint).toBe '/products'
