_ = require 'underscore'
Q = require 'q'
{TaskQueue} = require 'sphere-node-utils'
BaseService              = require '../../lib/services/base'
CartService              = require '../../lib/services/carts'
CategoryService          = require '../../lib/services/categories'
ChannelService           = require '../../lib/services/channels'
CommentService           = require '../../lib/services/comments'
CustomObjectService      = require '../../lib/services/custom-objects'
CustomerService          = require '../../lib/services/customers'
CustomerGroupService     = require '../../lib/services/customer-groups'
InventoryEntryService    = require '../../lib/services/inventory-entries'
MessageService           = require '../../lib/services/messages'
OrderService             = require '../../lib/services/orders'
ProductService           = require '../../lib/services/products'
ProductProjectionService = require '../../lib/services/product-projections'
ProductTypeService       = require '../../lib/services/product-types'
ReviewService            = require '../../lib/services/reviews'
ShippingMethodService    = require '../../lib/services/shipping-methods'
StateService             = require '../../lib/services/states'
TaxCategoryService       = require '../../lib/services/tax-categories'
ZoneService              = require '../../lib/services/zones'

describe 'Service', ->

  ID = '1234-abcd-5678-efgh'

  _.each [
    {name: 'BaseService', service: BaseService, path: ''}
    {name: 'CartService', service: CartService, path: '/carts'}
    {name: 'CategoryService', service: CategoryService, path: '/categories'}
    {name: 'ChannelService', service: ChannelService, path: '/channels'}
    {name: 'CommentService', service: CommentService, path: '/comments'}
    {name: 'CustomObjectService', service: CustomObjectService, path: '/custom-objects'}
    {name: 'CustomerService', service: CustomerService, path: '/customers'}
    {name: 'CustomerGroupService', service: CustomerGroupService, path: '/customer-groups'}
    {name: 'InventoryEntryService', service: InventoryEntryService, path: '/inventory'}
    {name: 'MessageService', service: MessageService, path: '/messages'}
    {name: 'OrderService', service: OrderService, path: '/orders'}
    {name: 'ProductService', service: ProductService, path: '/products'}
    {name: 'ProductProjectionService', service: ProductProjectionService, path: '/product-projections'}
    {name: 'ProductTypeService', service: ProductTypeService, path: '/product-types'}
    {name: 'ReviewService', service: ReviewService, path: '/reviews'}
    {name: 'ShippingMethodService', service: ShippingMethodService, path: '/shipping-methods'}
    {name: 'StateService', service: StateService, path: '/states'}
    {name: 'TaxCategoryService', service: TaxCategoryService, path: '/tax-categories'}
    {name: 'ZoneService', service: ZoneService, path: '/zones'}
  ], (o) ->

    describe ":: #{o.name}", ->

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
        @service = new o.service @restMock, @loggerMock, @task

      afterEach ->
        @service = null
        @restMock = null
        @loggerMock = null
        @task = null

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

      it 'should reset default params', ->
        expect(@service._params).toEqual
          query:
            where: []
            operator: 'and'
            sort: []

      it 'should build endpoint with id', ->
        @service.byId(ID)
        expect(@service._currentEndpoint).toBe "#{o.path}/#{ID}"

      _.each [
        ['byId', '1234567890']
        ['where', 'key = "foo"']
        ['whereOperator', 'and']
        ['page', 2]
        ['perPage', 5]
        ['sort', 'createdAt']
      ], (f) ->
        it "should chain '#{f[0]}'", ->
          clazz = @service[f[0]](f[1])
          expect(clazz).toEqual @service

          promise = @service[f[0]](f[1]).fetch()
          expect(Q.isPromise(promise)).toBe true

      it 'should add where predicates to query', ->
        @service.where('name(en="Foo")')
        expect(@service._params.query.where).toEqual ['name(en%3D%22Foo%22)']

        @service.where('variants is empty')
        expect(@service._params.query.where).toEqual ['name(en%3D%22Foo%22)', 'variants%20is%20empty']

      it 'should not add undefined where predicates', ->
        @service.where()
        expect(@service._params.query.where).toEqual []

      it 'should set query logical operator', ->
        @service.whereOperator('or')
        expect(@service._params.query.operator).toBe 'or'

        @service.whereOperator()
        expect(@service._params.query.operator).toBe 'and'

        @service.whereOperator('foo')
        expect(@service._params.query.operator).toBe 'and'

      _.each ['30s', '15m', '12h', '7d', '2w'], (type) ->
        it "should allow to query for last #{type}", ->
          @service.last(type)
          expect(@service._params.query.where[0]).toMatch /lastModifiedAt%20%3E%20%22201\d-\d\d-\d\dT\d\d%3A\d\d%3A\d\d.\d\d\dZ%22/

      it 'should throw an exception when the period for last can not be parsed', ->
        expect(=> @service.last('30')).toThrow new Error "Cannot parse period '30'"
        expect(=> @service.last('-1h')).toThrow new Error "Cannot parse period '-1h'"

      it 'should do nothing for 0 as input', ->
        @service.last('0m')
        expect(_.size @service._params.query.where).toBe 0

      it 'should add page number', ->
        @service.page(5)
        expect(@service._params.query.page).toBe 5

      it 'should throw if page < 1', ->
        expect(=> @service.page(0)).toThrow new Error 'Page must be a number >= 1'

      it 'should add perPage number', ->
        @service.perPage(50)
        expect(@service._params.query.perPage).toBe 50

      it 'should throw if perPage < 0', ->
        expect(=> @service.perPage(-1)).toThrow new Error 'PerPage (limit) must be a number >= 0'

      it 'should build query string', ->
        queryString = @service
          .where 'name(en="Foo")'
          .where 'id="1234567890"'
          .whereOperator 'or'
          .page 3
          .perPage 25
          .sort 'attrib', false
          .sort 'createdAt'
          ._queryString()

        expect(queryString).toBe 'where=name(en%3D%22Foo%22)%20or%20id%3D%221234567890%22&limit=25&offset=50&sort=attrib%20desc&sort=createdAt%20asc'

      _.each [
        ['fetch']
        ['save', {foo: 'bar'}]
        ['delete', 2]
      ], (f) ->
        it 'should reset params after creating a promise for #{f[0]}', ->
          _service = @service.byId('123-abc').where('name = "foo"').page(2).perPage(10).sort('id')
          expect(@service._params).toEqual
            id: '123-abc'
            query:
              where: [encodeURIComponent('name = "foo"')]
              operator: 'and'
              sort: [encodeURIComponent('id asc')]
              page: 2
              perPage: 10
          if f[1]
            _service[f[0]](f[1])
          else
            _service[f[0]]()
          expect(@service._params).toEqual
            query:
              where: []
              operator: 'and'
              sort: []

      it 'should pass original request to failed response', (done) ->
        spyOn(@service._rest, 'POST').andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 400}, {statusCode: 400, message: 'Oops, something went wrong'})
        @service.save({foo: 'bar'})
        .then -> done('Should not happen')
        .fail (error) ->
          expect(error).toEqual
            statusCode: 400
            message: 'Oops, something went wrong'
            originalRequest:
              endpoint: o.path
              payload: JSON.stringify(foo: 'bar')
          done()
        .done()

      describe ':: process', ->
        it 'should return promise', ->
          promise = @service.process( -> )
          expect(Q.isPromise(promise)).toBe true

        it 'should call process function for one page', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 1, results: []})
          fn = (payload) ->
            Q 'done'
          @service.process(fn)
          .then (result) ->
            expect(result).toEqual ['done']
            done()
          .fail (err) ->
            done err

        it 'should call process function for several page', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 90, endpoint: endpoint})
          fn = (payload) ->
            Q payload.body.endpoint
          @service.page(3).perPage(20).process(fn)
          .then (result) ->
            expect(_.size result).toBe 3
            expect(result[0]).toMatch /\?limit=20&offset=40$/
            expect(result[1]).toMatch /\?limit=20&offset=60$/
            expect(result[2]).toMatch /\?limit=20&offset=80$/
            done()
          .fail (err) ->
            done err

        it 'should fail if the process functions rejects', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 100})
          fn = (payload) ->
            Q.reject 'shit happens'
          @service.process(fn)
          .then (result) ->
            done 'not expected!'
          .fail (err) ->
            done()

        it 'should call each page with the same query', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 21, endpoint: endpoint})
          fn = (payload) ->
            Q payload.body.endpoint
          @service.where('foo=bar').whereOperator('or').sort('name DESC').process(fn)
          .then (result) ->
            expect(_.size result).toBe 2
            expect(result[0]).toMatch /\?where=foo%3Dbar&limit=20&sort=name%20DESC%20asc$/
            expect(result[1]).toMatch /\?where=foo%3Dbar&limit=20&offset=20&sort=name%20DESC%20asc$/
            done()
          .fail (err) ->
            done err

        it 'should throw error if function is missing', ->
          spyOn(@restMock, 'GET')
          expect(=> @service.process()).toThrow new Error 'Please provide a function to process the elements'
          expect(@restMock.GET).not.toHaveBeenCalled()

        it 'should handle pagination for changes in total', (done) ->
          total = 5
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: total--, results: []})
          fn = (payload) -> Q 'done'
          @service.perPage(1).process(fn)
          .then (result) ->
            expect(result).toEqual _.map [0..5], -> 'done'
            done()
          .fail (err) ->
            done err

      describe ':: fetch', ->

        it 'should return promise on fetch', ->
          promise = @service.fetch()
          expect(Q.isPromise(promise)).toBe true

        it 'should resolve the promise on fetch', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
          @service.fetch().then (result) ->
            expect(result.statusCode).toBe 200
            expect(result.body).toEqual foo: 'bar'
            done()

        it 'should reject the promise on fetch (404)', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
          @service.fetch()
          .then (result) -> done('Should not happen')
          .fail (error) ->
            expect(error).toEqual
              statusCode: 404
              message: "Endpoint '/foo' not found."
              originalRequest:
                endpoint: o.path
            done()

        it 'should return error message for endpoint not found with query', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
          @service
          .where()
          .page(1)
          .perPage()
          .fetch()
          .then (result) -> done('Should not happen')
          .fail (error) ->
            expect(error).toEqual
              statusCode: 404
              # message: "Endpoint '#{@service._currentEndpoint}?limit=100' not found."
              message: "Endpoint '/foo' not found."
              originalRequest:
                endpoint: o.path
            done()

        it 'should reject the promise on fetch', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback('foo', null, null)
          @service.fetch()
          .then (result) -> done('Should not happen')
          .fail (error) ->
            expect(error).toEqual
              statusCode: 500
              message: 'foo'
              originalRequest:
                endpoint: o.path
            done()

        it 'should send request with id, if provided', ->
          spyOn(@restMock, 'GET')
          @service.byId(ID).fetch()
          expect(@restMock.GET).toHaveBeenCalledWith "#{o.path}/#{ID}", jasmine.any(Function)

        describe ':: paged', ->

          it 'should resolve the promise on (paged) fetch', (done) ->
            spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 1, results: [{foo: 'bar'}]})
            @service.perPage(0).fetch()
            .then (result) ->
              expect(result.statusCode).toBe 200
              expect(result.body.total).toBe 1
              expect(result.body.results.length).toBe 1
              expect(result.body.results[0]).toEqual foo: 'bar'
              done()
            .fail (error) -> done(error)

          it 'should reject the promise on (paged) fetch (404)', (done) ->
            spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
            @service.perPage(0).fetch()
            .then (result) -> done('Should not happen')
            .fail (error) ->
              expect(error).toEqual
                statusCode: 404
                message: "Endpoint '/foo' not found."
                originalRequest:
                  endpoint: "#{o.path}?limit=0"
              done()

          it 'should reject the promise on (paged) fetch', (done) ->
            spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback('foo', null, null)
            @service.perPage(0).fetch()
            .then (result) -> done('Should not happen')
            .fail (error) ->
              expect(error).toEqual
                statusCode: 500
                message: 'foo'
                originalRequest:
                  endpoint: "#{o.path}?limit=0"
              done()

      describe ':: save', ->

        it 'should return promise on save', ->
          promise = @service.save {foo: 'bar'}
          expect(Q.isPromise(promise)).toBe true

        it 'should resolve the promise on save', (done) ->
          spyOn(@restMock, 'POST').andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
          @service.save({foo: 'bar'}).then (result) ->
            expect(result.statusCode).toBe 200
            expect(result.body).toEqual foo: 'bar'
            done()

        it 'should reject the promise on save (404)', (done) ->
          spyOn(@restMock, 'POST').andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
          @service.save({foo: 'bar'})
          .then (result) -> done('Should not happen')
          .fail (error) ->
            expect(error).toEqual
              statusCode: 404
              # message: "Endpoint '#{@service._currentEndpoint}' not found."
              message: "Endpoint '/foo' not found."
              originalRequest:
                endpoint: o.path
                payload: JSON.stringify(foo: 'bar')
            done()

        it 'should throw error if payload is missing', ->
          spyOn(@restMock, 'POST')
          expect(=> @service.save()).toThrow new Error "Body payload is required for creating a resource (endpoint: #{@service._currentEndpoint})"
          expect(@restMock.POST).not.toHaveBeenCalled()

        it 'should reject the promise on save', (done) ->
          spyOn(@restMock, 'POST').andCallFake (endpoint, payload, callback) -> callback('foo', null, null)
          @service.save({foo: 'bar'})
          .then (result) -> done('Should not happen')
          .fail (error) ->
            expect(error).toEqual
              statusCode: 500
              message: 'foo'
              originalRequest:
                endpoint: o.path
                payload: JSON.stringify(foo: 'bar')
            done()

        it 'should send request with id, if provided', ->
          spyOn(@restMock, 'POST')
          @service.byId(ID).save({foo: 'bar'})
          expect(@restMock.POST).toHaveBeenCalledWith "#{o.path}/#{ID}", JSON.stringify(foo: 'bar'), jasmine.any(Function)

      describe ':: create', ->

        it 'should be an alias for \'save\'', ->
          spyOn(@service, 'save')
          @service.create foo: 'bar'
          expect(@service.save).toHaveBeenCalledWith foo: 'bar'

      describe ':: update', ->

        it 'should be an alias for \'save\'', ->
          spyOn(@service, 'save')
          @service.update foo: 'bar'
          expect(@service.save).toHaveBeenCalledWith foo: 'bar'

      describe ':: delete', ->

        it 'should throw error if version is missing', ->
          spyOn(@restMock, 'DELETE')
          expect(=> @service.delete()).toThrow new Error "Version is required for deleting a resource (endpoint: #{@service._currentEndpoint})"
          expect(@restMock.DELETE).not.toHaveBeenCalled()

        it 'should return promise on delete', ->
          promise = @service.byId('123-abc').delete(1)
          expect(Q.isPromise(promise)).toBe true

        it 'should resolve the promise on delete', (done) ->
          spyOn(@restMock, 'DELETE').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
          @service.byId('123-abc').delete(1).then (result) ->
            expect(result.statusCode).toBe 200
            expect(result.body).toEqual foo: 'bar'
            done()

        it 'should reject the promise on delete (404)', (done) ->
          spyOn(@restMock, 'DELETE').andCallFake (endpoint, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
          @service.byId('123-abc').delete(1)
          .then (result) -> done('Should not happen')
          .fail (error) ->
            expect(error).toEqual
              statusCode: 404
              message: "Endpoint '/foo' not found."
              originalRequest:
                endpoint: "#{o.path}/123-abc?version=1"
            done()

        it 'should reject the promise on delete', (done) ->
          spyOn(@restMock, 'DELETE').andCallFake (endpoint, callback) -> callback('foo', null, null)
          @service.byId('123-abc').delete(1)
          .then (result) -> done('Should not happen')
          .fail (error) ->
            expect(error).toEqual
              statusCode: 500
              message: 'foo'
              originalRequest:
                endpoint: "#{o.path}/123-abc?version=1"
            done()
