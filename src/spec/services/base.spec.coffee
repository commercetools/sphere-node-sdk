_ = require('underscore')._
Q = require('q')
BaseService        = require('../../lib/services/base')
CartService        = require('../../lib/services/carts')
ChannelService     = require('../../lib/services/channels')
CategoryService    = require('../../lib/services/categories')
CustomerService    = require('../../lib/services/customers')
InventoryService   = require('../../lib/services/inventories')
OrderService       = require('../../lib/services/orders')
ProductService     = require('../../lib/services/products')
ProductTypeService = require('../../lib/services/product-types')
TaxCategoryService = require('../../lib/services/tax-categories')

describe 'Service', ->

  ID = "1234-abcd-5678-efgh"

  _.each [
    {name: 'BaseService', service: BaseService, path: ''}
    {name: 'CartService', service: CartService, path: '/carts'}
    {name: 'ChannelService', service: ChannelService, path: '/channels'}
    {name: 'CategoryService', service: CategoryService, path: '/categories'}
    {name: 'CustomerService', service: CustomerService, path: '/customers'}
    {name: 'InventoryService', service: InventoryService, path: '/inventory'}
    {name: 'OrderService', service: OrderService, path: '/orders'}
    {name: 'ProductService', service: ProductService, path: '/products'}
    {name: 'ProductTypeService', service: ProductTypeService, path: '/product-types'}
    {name: 'TaxCategoryService', service: TaxCategoryService, path: '/tax-categories'}
  ], (o)->

    describe ":: #{o.name}", ->

      beforeEach ->
        @restMock =
          config: {}
          GET: (endpoint, callback)->
          POST: ->
          PUT: ->
          DELETE: ->
          _preRequest: ->
          _doRequest: ->
        @service = new o.service @restMock

      afterEach ->
        @service = null
        @restMock = null

      it 'should have constants defined', ->
        expect(o.service.baseResourceEndpoint).toBe o.path

      it 'should not share variables between instances', ->
        base1 = new o.service @restMock
        base1._currentEndpoint = '/foo/1'
        base2 = new o.service @restMock
        expect(base2._currentEndpoint).toBe o.path

      it 'should initialize with Rest client', ->
        expect(@service).toBeDefined()
        expect(@service._currentEndpoint).toBe o.path

      it 'should return promise on fetch', ->
        promise = @service.fetch()
        expect(Q.isPromise(promise)).toBe true

      it 'should resolve the promise on fetch', (done)->
        spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback(null, {statusCode: 200}, '{"foo": "bar"}'))
        @service.fetch().then (result)->
          expect(result).toEqual foo: 'bar'
          done()

      it 'should reject the promise on fetch', (done)->
        spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback('foo', null, null))
        @service.fetch().then (result)->
          expect(result).not.toBeDefined()
        .fail (e)->
          expect(e).toBe 'foo'
          done()

      it 'should build endpoint with id', ->
        @service.byId(ID)
        expect(@service._currentEndpoint).toBe "#{o.path}/#{ID}"

      it 'should chain "byId"', ->
        clazz = @service.byId(ID)
        expect(clazz).toEqual @service

        promise = @service.byId(ID).fetch()
        expect(Q.isPromise(promise)).toBe true
