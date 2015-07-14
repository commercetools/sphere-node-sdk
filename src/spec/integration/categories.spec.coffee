debug = require('debug')('spec-integration:categories')
_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient} = require '../../lib/main'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newCategory = (name = 'Category name') ->
  name:
    en: name
  slug:
    en: uniqueId 'c'

updateCategory = (version, parentId) ->
  version: version
  actions: [
    {action: 'changeParent', parent: {typeId: 'category', id: parentId}}
  ]

describe 'Integration Categories', ->

  beforeEach (done) ->
    @client = new SphereClient config: Config

    debug 'Creating 10 categories'
    Promise.all _.map [1..10], => @client.categories.save(newCategory())
    .then (results) ->
      debug "Created #{results.length} categories"
      done()
    .catch (error) -> done(_.prettify(error))
  , 30000 # 30sec

  afterEach (done) ->
    debug 'About to delete all categories'
    @client.categories.process (payload) =>
      debug "Deleting #{payload.body.total} categories"
      Promise.map payload.body.results, (category) =>
        @client.categories.byId(category.id).delete(category.version)
    .then (results) ->
      debug "Deleted #{results.length} categories"
      done()
    .catch (error) -> done(_.prettify(error))
  , 60000 # 1min

  it 'should update descriptions with process', (done) ->
    @client.categories.sort('id').perPage(1).process (payload) =>
      cat = payload.body.results[0]
      if cat
        @client.categories.byId(cat.id).update
          version: cat.version
          actions: [
            {action: 'setDescription', description: {en: 'A new description'}}
          ]
      else
        debug 'No category found, skipping...'
        Promise.resolve()
    .then (results) ->
      expect(results.length).toBe 10
      done()
    .catch (error) -> done(_.prettify(error))
  , 120000 # 2min

  it 'should traverse all pages for given predicate', (done) ->
    debug 'creating category A'
    Promise.map [1..100], (i) =>
      @client.categories.save(newCategory('FooA'))
    , {concurrency: 20}
    .then (result) =>
      debug "created #{result.length} categories A"
      debug 'creating category B'
      Promise.map [1..10], (i) =>
        @client.categories.save(newCategory('FooB'))
    .then (result) =>
      debug "created #{result.length} categories B"
      debug 'query for category A'
      @client.categories.all().where('name(en = "FooA")').fetch()
    .then (result) =>
      expect(result.body.total).toBe 100
      expect(result.body.results.length).toBe 100

      debug 'query for category B'
      @client.categories.all().where('name(en = "FooB")').fetch()
    .then (result) =>
      expect(result.body.total).toBe 10
      expect(result.body.results.length).toBe 10

      debug 'cleanup categories'
      @client.categories
      .where('name(en = "FooA")')
      .where('name(en = "FooB")')
      .whereOperator('or')
      .perPage(20)
      .process (payload) =>
        debug 'fetched categories: %j', payload
        Promise.map payload.body.results, (group) =>
          @client.categories.byId(group.id).delete(group.version)
    .then (results) ->
      debug "Deleted #{results.length} categories"
      expect(results.length).toBe 110
      done()
    .catch (error) -> done _.prettify(error)
  , 30000 # 30sec
