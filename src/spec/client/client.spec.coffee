_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, Rest} = require '../../lib/main'
TaskQueue = require '../../lib/task-queue'
Config = require('../../config').config

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
    expect(@client._task).toBeDefined()
    expect(@client.carts).toBeDefined()
    expect(@client.categories).toBeDefined()
    expect(@client.channels).toBeDefined()
    expect(@client.comments).toBeDefined()
    expect(@client.customObjects).toBeDefined()
    expect(@client.customers).toBeDefined()
    expect(@client.customerGroups).toBeDefined()
    expect(@client.inventoryEntries).toBeDefined()
    expect(@client.messages).toBeDefined()
    expect(@client.orders).toBeDefined()
    expect(@client.products).toBeDefined()
    expect(@client.productDiscounts).toBeDefined()
    expect(@client.productProjections).toBeDefined()
    expect(@client.productTypes).toBeDefined()
    expect(@client.reviews).toBeDefined()
    expect(@client.shippingMethods).toBeDefined()
    expect(@client.states).toBeDefined()
    expect(@client.taxCategories).toBeDefined()
    expect(@client.zones).toBeDefined()

  it 'should throw error if no credentials are given', ->
    client = -> new SphereClient foo: 'bar'
    expect(client).toThrow new Error('Missing credentials')

  _.each ['client_id', 'client_secret', 'project_key'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config)
      delete opt[key]
      client = -> new SphereClient config: opt
      expect(client).toThrow new Error("Missing '#{key}'")

  it 'should initialize with given Rest', ->
    existingRest = new Rest config: Config
    client = new SphereClient rest: existingRest
    expect(client._rest).toEqual existingRest

  it 'should initialize with given TaskQueue', ->
    existingTaskQueue = new TaskQueue
    client = new SphereClient
      config: Config
      task: existingTaskQueue
    expect(client._task).toEqual existingTaskQueue

  it 'should set maxParallel requests globally', ->
    @client.setMaxParallel(5)
    expect(@client._task._maxParallel).toBe 5

  it 'should throw if maxParallel < 1 or > 100', ->
    expect(=> @client.setMaxParallel(0)).toThrow new Error 'MaxParallel must be a number between 1 and 100'
    expect(=> @client.setMaxParallel(101)).toThrow new Error 'MaxParallel must be a number between 1 and 100'


  _.each [
    'carts'
    'categories'
    'channels'
    'comments'
    'customObjects'
    'customers'
    'customerGroups'
    'inventoryEntries'
    'messages'
    'orders'
    'products'
    'productDiscounts'
    'productProjections'
    'productTypes'
    'reviews'
    'shippingMethods'
    'states'
    'taxCategories'
    'zones'
  ], (name) ->

    describe ":: #{name}", ->

      ID = "1234-abcd-5678-efgh"

      it 'should enable statistic (headers)', ->
        expect(@client[name]._stats.includeHeaders).toBe false
        client = new SphereClient
          config: Config
          stats:
            includeHeaders: true
        expect(client[name]._stats.includeHeaders).toBe true

      it 'should query resource', (done) ->
        spyOn(@client._rest, "GET").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service
        .where('name(en="Foo")')
        .whereOperator('or')
        .page(2)
        .perPage(5)
        .fetch().then (result) ->
          expect(result.statusCode).toBe 200
          expect(result.body).toEqual foo: 'bar'
          done()
        .catch (e) -> done(_.prettify(error))

      it 'should get resource by id', (done) ->
        spyOn(@client._rest, "GET").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service.byId(ID).fetch().then (result) ->
          expect(result.statusCode).toBe 200
          expect(result.body).toEqual foo: 'bar'
          done()
        .catch (e) -> done(_.prettify(error))

      it 'should save new resource', (done) ->
        spyOn(@client._rest, "POST").andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service.save({foo: 'bar'}).then (result) ->
          expect(result.statusCode).toBe 200
          expect(result.body).toEqual foo: 'bar'
          done()
        .catch (e) -> done(_.prettify(error))

      it 'should delete resource', (done) ->
        spyOn(@client._rest, "DELETE").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[name]
        service.byId('123-abc').delete(4).then (result) =>
          expect(result.statusCode).toBe 200
          expect(result.body).toEqual foo: 'bar'
          expect(@client._rest.DELETE).toHaveBeenCalledWith "#{service._currentEndpoint}/123-abc?version=4", jasmine.any(Function)
          done()
        .catch (e) -> done(_.prettify(error))
