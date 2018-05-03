debug = require('debug')('spec-integration:products')
_ = require 'underscore'
Promise = require 'bluebird'
{SphereClient} = require '../../lib/main'
Config = require('../../config').config

newProductType = ->
  name: 'Vehicle'
  description: 'A sample type of vehicle'

describe 'gzip compression', ->

  afterEach (done) ->
    debug 'About to delete all product types'
    @client.products.all().fetch()
    .then (payload) =>
      debug "Deleting #{payload.body.total} products"
      Promise.all _.map payload.body.results, (product) =>
        @client.products.byId(product.id).delete(product.version)
    .then () =>
      @client.productTypes.all().fetch()
    .then (payload) =>
      debug "Deleting #{payload.body.total} product types"
      Promise.all _.map payload.body.results, (productType) =>
        @client.productTypes.byId(productType.id).delete(productType.version)
    .then (results) ->
      debug "Deleted #{results.length} product types"
      done()
    .catch (error) -> done(_.prettify(error))
  , 20000 # 20 sec

  it 'should use gzip compression by default for all requests', (done) ->
    @client = new SphereClient
      config: Config
      stats:
        includeHeaders: true
    debug 'Creating a ProductType'
    @client.productTypes.save(newProductType())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @client.productTypes.fetch()
    .then (results) ->
      gzipReqHeader = results.http.request.headers['accept-encoding']
      gzipResHeader = results.http.response.headers['content-encoding']
      expect(gzipReqHeader).toBeTruthy()
      expect(gzipReqHeader).toMatch /gzip/
      expect(gzipResHeader).toBeTruthy()
      expect(gzipResHeader).toMatch /gzip/
      done()
    .catch (error) -> done(_.prettify(error))
  , 20000 # 20 sec

  it 'should not use gzip compression when disbled', (done) ->
    @client = new SphereClient
      config: Config
      stats:
        includeHeaders: true
      gzipEnable: false
    debug 'Creating a ProductType'
    @client.productTypes.save(newProductType())
    .then (result) =>
      expect(result.statusCode).toBe 201
      @client.productTypes.fetch()
    .then (results) ->
      gzipReqHeader = results.http.request.headers['accept-encoding']
      gzipResHeader = results.http.response.headers['content-encoding']
      expect(gzipReqHeader).not.toBeDefined()
      expect(gzipResHeader).not.toBeDefined()
      done()
    .catch (error) -> done(_.prettify(error))
  , 20000 # 20 sec
