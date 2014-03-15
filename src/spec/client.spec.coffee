_ = require 'underscore'
SphereClient = require '../lib/client'
Logger = require '../lib/logger'
Config = require('../config').config

class MyLogger extends Logger
  @appName: 'foo'
  @path: './foo-test.log'

describe 'SphereClient', ->

  beforeEach ->
    @client = new SphereClient config: Config

  afterEach ->
    @client = null

  it 'should read credentials', ->
    expect(Config.client_id).toBeDefined()
    expect(Config.client_secret).toBeDefined()
    expect(Config.project_key).toBeDefined()

  it 'should initialize with credentials', ->
    expect(@client).toBeDefined()
    expect(@client._rest).toBeDefined()
    expect(@client.carts).toBeDefined()
    expect(@client.categories).toBeDefined()
    expect(@client.channels).toBeDefined()
    expect(@client.comments).toBeDefined()
    expect(@client.customObjects).toBeDefined()
    expect(@client.customers).toBeDefined()
    expect(@client.customerGroups).toBeDefined()
    expect(@client.inventories).toBeDefined()
    expect(@client.orders).toBeDefined()
    expect(@client.products).toBeDefined()
    expect(@client.productProjections).toBeDefined()
    expect(@client.productTypes).toBeDefined()
    expect(@client.reviews).toBeDefined()
    expect(@client.shippingMethods).toBeDefined()
    expect(@client.taxCategories).toBeDefined()

  it 'should throw error if no credentials are given', ->
    client = -> new SphereClient foo: 'bar'
    expect(client).toThrow new Error('Missing credentials')

  _.each ['client_id', 'client_secret', 'project_key'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config)
      delete opt[key]
      client = -> new SphereClient config: opt
      expect(client).toThrow new Error("Missing '#{key}'")

  it 'should initialize and extend logger', ->
    expect(@client._rest.logger).toBeDefined()
    expect(@client._rest.logger.fields.name).toBe 'sphere-node-client'
    expect(@client._rest.logger.streams[1].path).toBe './sphere-node-client-debug.log'
    expect(@client._rest.logger.fields.widget_type).toBe 'sphere-node-connect'

  it 'should initialize with given logger', ->
    existingLogger = new MyLogger()
    client = new SphereClient
      config: Config
      logConfig:
        logger: existingLogger

    expect(client._logger.fields.name).toBe 'foo'
    expect(client._logger.streams[1].path).toBe './foo-test.log'
    expect(client._logger.fields.widget_type).toBe 'sphere-node-client'
    expect(client._rest.logger.fields.widget_type).toBe 'sphere-node-connect'

  _.each [
    'carts'
    'categories'
    'channels'
    'comments'
    'customObjects'
    'customers'
    'customerGroups'
    'inventories'
    'orders'
    'products'
    'productProjections'
    'productTypes'
    'reviews'
    'shippingMethods'
    'taxCategories'
  ], (name) ->

    describe ":: #{name}", ->

      ID = "1234-abcd-5678-efgh"

      it 'should query resource', (done) ->
        spyOn(@client._rest, "GET").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service
        .where('name(en="Foo")')
        .whereOperator('or')
        .page(2)
        .perPage(5)
        .fetch().then (result) ->
          expect(result).toEqual foo: 'bar'
          done()

      it 'should get resource by id', (done) ->
        spyOn(@client._rest, "GET").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service.byId(ID).fetch().then (result) ->
          expect(result).toEqual foo: 'bar'
          done()

      it 'should save new resource', (done) ->
        spyOn(@client._rest, "POST").andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service.save({foo: 'bar'}).then (result) ->
          expect(result).toEqual foo: 'bar'
          done()

      it 'should delete resource', (done) ->
        spyOn(@client._rest, "DELETE").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service.byId('123-abc').delete(4).then (result) =>
          expect(result).toEqual foo: 'bar'
          expect(@client._rest.DELETE).toHaveBeenCalledWith "#{service._currentEndpoint}/123-abc?version=4", jasmine.any(Function)
          done()
