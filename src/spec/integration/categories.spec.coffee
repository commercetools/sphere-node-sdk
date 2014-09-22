debug = require('debug')('spec-sphere-client-categories')
_ = require 'underscore'
Q = require 'q'
_.mixin require('underscore-mixins')
SphereClient = require '../../lib/client'
Config = require('../../config').config

uniqueId = (prefix) ->
  _.uniqueId "#{prefix}#{new Date().getTime()}_"

newCategory = ->
  name:
    en: 'Category name'
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

    debug 'Creating 50 categories'
    Q.all _.map [1..50], => @client.categories.save(newCategory())
    .then (results) ->
      debug "Created #{results.length} categories"
      done()
    .fail (error) -> done(_.prettify(error))
  , 30000 # 30sec

  afterEach (done) ->
    debug 'About to delete all categories'
    @client.categories.perPage(0).fetch()
    .then (payload) =>
      debug "Deleting #{payload.body.total} categories (maxParallel: 1)"
      @client.setMaxParallel(1)
      Q.all _.map payload.body.results, (category) =>
        @client.categories.byId(category.id).delete(category.version)
    .then (results) ->
      debug "Deleted #{results.length} categories"
      done()
    .fail (error) -> done(_.prettify(error))
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
        Q()
    .then (results) ->
      expect(results.length).toBe 50
      done()
    .fail (error) -> done(_.prettify(error))
  , 120000 # 2min
