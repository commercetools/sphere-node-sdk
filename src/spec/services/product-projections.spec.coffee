Q = require 'q'
_ = require 'underscore'
{TaskQueue} = require 'sphere-node-utils'
ProductProjectionService = require '../../lib/services/product-projections'

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
    @loggerMock =
      trace: ->
      debug: ->
      info: ->
      warn: ->
      error: ->
      fatal: ->
    @task = new TaskQueue
    @service = new ProductProjectionService @restMock, @loggerMock, @task

  it 'should reset default params', ->
    expect(@service._customParams).toEqual
      query:
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
    expect(@service._customParams).toEqual
      query:
        staged: true
        lang: 'de'
        text: 'foo'
        filter: [encodeURIComponent('foo:bar')]
        filterByQuery: [encodeURIComponent('foo:bar')]
        filterByFacets: [encodeURIComponent('foo:bar')]
        facet: [encodeURIComponent('foo:bar')]
    _service.search()
    expect(@service._customParams).toEqual
      query:
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
