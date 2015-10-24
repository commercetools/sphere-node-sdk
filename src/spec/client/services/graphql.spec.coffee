_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{TaskQueue} = require '../../../lib/main'
GraphQLService = require '../../../lib/services/graphql'

###*
 * Describe service specific implementations
###
describe 'GraphQLService', ->

  beforeEach ->
    @restMock =
      config: {}
      GET: (endpoint, callback) ->
      POST: -> (endpoint, payload, callback) ->
      PUT: ->
      DELETE: -> (endpoint, callback) ->
      PAGED: -> (endpoint, callback) ->
      _preRequest: ->
      _doRequest: ->
    @task = new TaskQueue
    @graphql = new GraphQLService
      _rest: @restMock
      _task: @task
      _stats:
        includeHeaders: false

  it 'should have constants defined', ->
    expect(GraphQLService.baseResourceEndpoint).toBe '/graphql'

  it 'should resolve the promise on save', (done) ->
    query = {query: 'query Foo { bar }'}
    spyOn(@restMock, 'POST').andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 200}, {data: { foo: 'bar' }, errors: null})
    @graphql.query(query).then (result) =>
      expect(@restMock.POST).toHaveBeenCalledWith jasmine.any(String), query, jasmine.any(Function)
      done()
    .catch (error) -> done(_.prettify(error))
