_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{SphereClient, Rest, TaskQueue} = require '../../lib/main'
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

  it 'should initialize services', ->
    expect(@client).toBeDefined()
    expect(@client._rest).toBeDefined()
    expect(@client._rest._options.headers['User-Agent']).toBe 'sphere-node-sdk'
    expect(@client._task).toBeDefined()
    expect(@client.cartDiscounts).toBeDefined()
    expect(@client.carts).toBeDefined()
    expect(@client.categories).toBeDefined()
    expect(@client.channels).toBeDefined()
    expect(@client.customObjects).toBeDefined()
    expect(@client.customers).toBeDefined()
    expect(@client.customerGroups).toBeDefined()
    expect(@client.discountCodes).toBeDefined()
    expect(@client.graphql).toBeDefined()
    expect(@client.inventoryEntries).toBeDefined()
    expect(@client.messages).toBeDefined()
    expect(@client.orders).toBeDefined()
    expect(@client.payments).toBeDefined()
    expect(@client.products).toBeDefined()
    expect(@client.productDiscounts).toBeDefined()
    expect(@client.productProjections).toBeDefined()
    expect(@client.productTypes).toBeDefined()
    expect(@client.reviews).toBeDefined()
    expect(@client.shippingMethods).toBeDefined()
    expect(@client.states).toBeDefined()
    expect(@client.taxCategories).toBeDefined()
    expect(@client.types).toBeDefined()
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

  it 'should not repeat request on error if repeater is disabled',(done) ->
    client =  new SphereClient {config: Config, enableRepeater: false}
    callsMap = {
      0: { statusCode: 500, message: 'ETIMEDOUT' }
      1: { statusCode: 500, message: 'ETIMEDOUT' }
      2: { statusCode: 200, message: 'success' }
    }
    callCount = 0
    spyOn(client._rest, 'GET').andCallFake (resource, callback) ->
      currentCall = callsMap[callCount]
      callCount++
      statusCode = currentCall.statusCode
      message = currentCall.message
      callback(null, { statusCode }, { message })

    client.products.fetch()
    .catch (err) ->
      expect(client._rest.GET.calls.length).toEqual 1
      expect(err.body.message).toEqual 'ETIMEDOUT'
      done()

  _.each [
    {name: 'cartDiscounts', className: 'CartDiscountService', blacklist: []}
    {name: 'carts', className: 'CartService', blacklist: []}
    {name: 'categories', className: 'CategoryService', blacklist: []}
    {name: 'channels', className: 'ChannelService', blacklist: []}
    {name: 'customObjects', className: 'CustomObjectService', blacklist: []}
    {name: 'customers', className: 'CustomerService', blacklist: []}
    {name: 'customerGroups', className: 'CustomerGroupService', blacklist: []}
    {name: 'discountCodes', className: 'DiscountCodeService', blacklist: []}
    {name: 'inventoryEntries', className: 'InventoryEntryService', blacklist: []}
    {name: 'messages', className: 'MessageService', blacklist: ['save', 'create', 'update', 'delete']}
    {name: 'orders', className: 'OrderService', blacklist: ['delete']}
    {name: 'payments', className: 'PaymentService', blacklist: []}
    {name: 'products', className: 'ProductService', blacklist: []}
    {name: 'productDiscounts', className: 'ProductDiscountService', blacklist: []}
    {name: 'productProjections', className: 'ProductProjectionService', blacklist: ['save', 'create', 'update', 'delete']}
    {name: 'productTypes', className: 'ProductTypeService', blacklist: []}
    {name: 'reviews', className: 'ReviewService', blacklist: ['delete']}
    {name: 'shippingMethods', className: 'ShippingMethodService', blacklist: []}
    {name: 'states', className: 'StateService', blacklist: []}
    {name: 'taxCategories', className: 'TaxCategoryService', blacklist: []}
    {name: 'types', className: 'TypeService', blacklist: []}
    {name: 'zones', className: 'ZoneService', blacklist: []}
  ], (serviceDef) ->

    describe ":: #{serviceDef.name}", ->

      ID = "1234-abcd-5678-efgh"

      it 'should get service', ->
        service = @client[serviceDef.name]
        expect(service).toBeDefined()
        expect(service.constructor.name).toBe(serviceDef.className)

      it 'should enable statistic (headers)', ->
        expect(@client[serviceDef.name]._stats.includeHeaders).toBe false
        client = new SphereClient
          config: Config
          stats:
            includeHeaders: true
        expect(client[serviceDef.name]._stats.includeHeaders).toBe true

      it 'should query resource', (done) ->
        spyOn(@client._rest, "GET").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[serviceDef.name]
        service
        .where('name(en="Foo")')
        .whereOperator('or')
        .page(2)
        .perPage(5)
        .fetch().then (result) ->
          expect(result.statusCode).toBe 200
          expect(result.body).toEqual foo: 'bar'
          done()
        .catch (e) -> done(_.prettify(e))

      it 'should get resource by id', (done) ->
        spyOn(@client._rest, "GET").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
        service = @client[serviceDef.name]
        service.byId(ID).fetch().then (result) ->
          expect(result.statusCode).toBe 200
          expect(result.body).toEqual foo: 'bar'
          done()
        .catch (e) -> done(_.prettify(e))

      if not _.contains(serviceDef.blacklist, 'save')

        it 'should save new resource', (done) ->
          spyOn(@client._rest, "POST").andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
          service = @client[serviceDef.name]
          service.save({foo: 'bar'}).then (result) ->
            expect(result.statusCode).toBe 200
            expect(result.body).toEqual foo: 'bar'
            done()
          .catch (e) -> done(_.prettify(e))

      if not _.contains(serviceDef.blacklist, 'delete')

        it 'should delete resource', (done) ->
          spyOn(@client._rest, "DELETE").andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
          service = @client[serviceDef.name]
          service.byId('123-abc').delete(4).then (result) =>
            expect(result.statusCode).toBe 200
            expect(result.body).toEqual foo: 'bar'
            expect(@client._rest.DELETE).toHaveBeenCalledWith "#{service._currentEndpoint}/123-abc?version=4", jasmine.any(Function)
            done()
          .catch (e) -> done(_.prettify(e))
