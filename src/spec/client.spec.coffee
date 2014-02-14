_ = require('underscore')._
SphereClient = require '../lib/client'
Config = require('../config').config

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
    expect(@client.categories).toBeDefined()
    expect(@client.products).toBeDefined()

  it 'should throw error if no credentials are given', ->
    client = -> new SphereClient foo: 'bar'
    expect(client).toThrow new Error('Missing credentials')

  _.each ['client_id', 'client_secret', 'project_key'], (key) ->
    it "should throw error if no '#{key}' is defined", ->
      opt = _.clone(Config)
      delete opt[key]
      client = -> new SphereClient config: opt
      expect(client).toThrow new Error("Missing '#{key}'")

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
