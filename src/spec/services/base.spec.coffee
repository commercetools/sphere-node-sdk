_ = require('underscore')._
Q = require('q')
BaseService              = require('../../lib/services/base')
CartService              = require('../../lib/services/carts')
CategoryService          = require('../../lib/services/categories')
ChannelService           = require('../../lib/services/channels')
CommentService           = require('../../lib/services/comments')
CustomObjectService      = require('../../lib/services/custom-objects')
CustomerService          = require('../../lib/services/customers')
CustomerGroupService     = require('../../lib/services/customer-groups')
InventoryService         = require('../../lib/services/inventories')
OrderService             = require('../../lib/services/orders')
ProductService           = require('../../lib/services/products')
ProductProjectionService = require('../../lib/services/product-projections')
ProductTypeService       = require('../../lib/services/product-types')
ReviewService            = require('../../lib/services/reviews')
ShippingMethodService    = require('../../lib/services/shipping-methods')
TaxCategoryService       = require('../../lib/services/tax-categories')

describe 'Service', ->

  ID = "1234-abcd-5678-efgh"

  _.each [
    {name: 'BaseService', service: BaseService, path: ''}
    {name: 'CartService', service: CartService, path: '/carts'}
    {name: 'CategoryService', service: CategoryService, path: '/categories'}
    {name: 'ChannelService', service: ChannelService, path: '/channels'}
    {name: 'CommentService', service: CommentService, path: '/comments'}
    {name: 'CustomObjectService', service: CustomObjectService, path: '/custom-objects'}
    {name: 'CustomerService', service: CustomerService, path: '/customers'}
    {name: 'CustomerGroupService', service: CustomerGroupService, path: '/customer-groups'}
    {name: 'InventoryService', service: InventoryService, path: '/inventory'}
    {name: 'OrderService', service: OrderService, path: '/orders'}
    {name: 'ProductService', service: ProductService, path: '/products'}
    {name: 'ProductProjectionService', service: ProductProjectionService, path: '/product-projections'}
    {name: 'ProductTypeService', service: ProductTypeService, path: '/product-types'}
    {name: 'ReviewService', service: ReviewService, path: '/reviews'}
    {name: 'ShippingMethodService', service: ShippingMethodService, path: '/shipping-methods'}
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

      it 'should resolve the promise on fetch (404)', (done)->
        spyOn(@restMock, 'GET').andCallFake((endpoint, callback)-> callback(null, {statusCode: 404}, ''))
        @service.fetch().then (result)=>
          expect(result).toEqual
            statusCode: 404
            message: "Endpoint '#{@service._currentEndpoint}' not found."
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

      _.each ['byId', 'where', 'whereOperator'], (f)->
        it "should chain '#{f}'", ->
          clazz = @service[f]()
          expect(clazz).toEqual @service

          promise = @service[f]().fetch()
          expect(Q.isPromise(promise)).toBe true

      it 'should add where predicates to query', ->
        @service.where('name(en="Foo")')
        expect(@service._query).toEqual ['name(en%3D%22Foo%22)']

        @service.where('variants is empty')
        expect(@service._query).toEqual ['name(en%3D%22Foo%22)', 'variants%20is%20empty']

      it 'should set query logical operator', ->
        @service.whereOperator('or')
        expect(@service._queryOperator).toBe 'or'

        @service.whereOperator()
        expect(@service._queryOperator).toBe 'and'

        @service.whereOperator('foo')
        expect(@service._queryOperator).toBe 'and'
