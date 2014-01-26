BaseService = require('../../lib/services/base')

describe 'BaseService', ->

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

  it 'should initialize with Rest client', ->
    base = new BaseService @restMock
    expect(base).toBeDefined()
    expect(base._projectEndpoint).toBe '/'

  xit 'should return promise on fetch', ->
