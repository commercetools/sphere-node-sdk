Q = require 'q'
_ = require 'underscore'
_.mixin require 'underscore-mixins'
TaskQueue = require '../../../lib/task-queue'
ProductProjectionService = require '../../../lib/services/product-projections'

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
      DELETE: -> (endpoint, callback) ->
      PAGED: -> (endpoint, callback, notify) ->
      _preRequest: ->
      _doRequest: ->
    @task = new TaskQueue
    @service = new ProductProjectionService
      _rest: @restMock
      _task: @task
      _stats:
        includeHeaders: false

  it 'should reset default params', ->
    expect(@service._params).toEqual
      query:
        where: []
        operator: 'and'
        sort: []
        expand: []
        staged: false
        filter: []
        filterByQuery: []
        filterByFacets: []
        facet: []

  _.each [
    ['staged', false]
    ['lang', 'de']
    ['text', 'foo']
    ['filter', 'foo:bar']
    ['filterByQuery', 'foo:bar']
    ['filterByFacets', 'foo:bar']
    ['facet', 'foo:bar']
  ], (f) ->
    it "should chain search function '#{f[0]}'", ->
      clazz = @service[f[0]](f[1])
      expect(clazz).toEqual @service

      promise = @service[f[0]](f[1]).search()
      expect(Q.isPromise(promise)).toBe true

  it 'should query for staged', ->
    expect(@service.staged()._queryString()).toBe 'staged=true'

  it 'should query for published', ->
    expect(@service.staged(false)._queryString()).toBe ''

  it 'should query for lang', ->
    expect(@service.lang('de')._queryString()).toBe 'lang=de'

  it 'should throw if lang is not defined', ->
    expect(=> @service.lang()).toThrow new Error 'Language parameter is required for searching'

  it 'should query for text', ->
    expect(@service.text('foo')._queryString()).toBe 'text=foo'

  it 'should query for filter', ->
    expect(@service.filter('foo:bar')._queryString()).toBe 'filter=foo%3Abar'

  it 'should query for filter.query', ->
    expect(@service.filterByQuery('foo:bar')._queryString()).toBe 'filter.query=foo%3Abar'

  it 'should query for filter.facets', ->
    expect(@service.filterByFacets('foo:bar')._queryString()).toBe 'filter.facets=foo%3Abar'

  it 'should query for facet', ->
    expect(@service.facet('foo:bar')._queryString()).toBe 'facet=foo%3Abar'

  it 'should build search query string', ->
    queryString = @service
      .page 3
      .perPage 25
      .sort('createdAt')
      .lang('de')
      .text('foo')
      .filter('foo:bar')
      .filterByQuery('foo:bar')
      .filterByFacets('foo:bar')
      .facet('foo:bar')
      ._queryString()

    expect(queryString).toBe 'limit=25&offset=50&sort=createdAt%20asc&lang=de&text=foo&filter=foo%3Abar&filter.query=foo%3Abar&filter.facets=foo%3Abar&facet=foo%3Abar'

  it "should reset search custom params after creating a promise", ->
    _service = @service
      .page 3
      .perPage 25
      .sort('createdAt')
      .staged()
      .lang('de')
      .text('foo')
      .filter('foo:bar')
      .filterByQuery('foo:bar')
      .filterByFacets('foo:bar')
      .facet('foo:bar')
    expect(@service._params).toEqual
      query:
        where: []
        operator: 'and'
        sort: [encodeURIComponent('createdAt asc')]
        expand: []
        page: 3
        perPage: 25
        staged: true
        lang: 'de'
        text: 'foo'
        filter: [encodeURIComponent('foo:bar')]
        filterByQuery: [encodeURIComponent('foo:bar')]
        filterByFacets: [encodeURIComponent('foo:bar')]
        facet: [encodeURIComponent('foo:bar')]
    _service.search()
    expect(@service._params).toEqual
      query:
        where: []
        operator: 'and'
        sort: []
        expand: []
        staged: false
        filter: []
        filterByQuery: []
        filterByFacets: []
        facet: []

  describe ':: search', ->

    it 'should call \'fetch\' after setting search endpoint', ->
      spyOn(@service, 'fetch')
      @service.lang('de').filter('foo:bar').search()
      expect(@service.fetch).toHaveBeenCalled()
      expect(@service._currentEndpoint).toBe '/product-projections/search'

  describe ':: fetch', ->

    it 'should fetch all with defaul sorting', (done) ->
      spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 1, results: []})
      @service.where('foo=bar').staged(true).all().fetch()
      .then (result) =>
        expect(@restMock.PAGED).toHaveBeenCalledWith "/product-projections?where=foo%3Dbar&limit=0&sort=id%20asc&staged=true", jasmine.any(Function), jasmine.any(Function)
        done()
      .fail (err) -> done(_.prettify error)

  describe ':: process', ->

    it 'should call each page with the same query (default sorting)', (done) ->
      spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 21, endpoint: endpoint})
      fn = (payload) ->
        Q payload.body.endpoint
      @service.where('foo=bar').whereOperator('or').staged(true).process(fn)
      .then (result) ->
        expect(_.size result).toBe 2
        expect(result[0]).toMatch /\?where=foo%3Dbar&limit=20&sort=id%20asc&staged=true$/
        expect(result[1]).toMatch /\?where=foo%3Dbar&limit=20&offset=20&sort=id%20asc&staged=true$/
        done()
      .fail (err) -> done(_.prettify error)

    it 'should call each page with the same query (given sorting)', (done) ->
      spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 21, endpoint: endpoint})
      fn = (payload) ->
        Q payload.body.endpoint
      @service.where('foo=bar').whereOperator('or').staged(true).sort('name', false).process(fn)
      .then (result) ->
        expect(_.size result).toBe 2
        expect(result[0]).toMatch /\?where=foo%3Dbar&limit=20&sort=name%20desc&staged=true$/
        expect(result[1]).toMatch /\?where=foo%3Dbar&limit=20&offset=20&sort=name%20desc&staged=true$/
        done()
      .fail (err) -> done(_.prettify error)
