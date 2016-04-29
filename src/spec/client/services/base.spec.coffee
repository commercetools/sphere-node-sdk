_ = require 'underscore'
_.mixin require 'underscore-mixins'
Promise = require 'bluebird'
{TaskQueue} = require '../../../lib/main'
BaseService              = require '../../../lib/services/base'
CartDiscountService      = require '../../../lib/services/cart-discounts'
CartService              = require '../../../lib/services/carts'
CategoryService          = require '../../../lib/services/categories'
ChannelService           = require '../../../lib/services/channels'
CustomObjectService      = require '../../../lib/services/custom-objects'
CustomerService          = require '../../../lib/services/customers'
CustomerGroupService     = require '../../../lib/services/customer-groups'
DiscountCodeService      = require '../../../lib/services/discount-codes'
InventoryEntryService    = require '../../../lib/services/inventory-entries'
MessageService           = require '../../../lib/services/messages'
OrderService             = require '../../../lib/services/orders'
PaymentService           = require '../../../lib/services/payments'
ProductService           = require '../../../lib/services/products'
ProductDiscountService   = require '../../../lib/services/product-discounts'
ProductProjectionService = require '../../../lib/services/product-projections'
ProductTypeService       = require '../../../lib/services/product-types'
ProjectService           = require '../../../lib/services/project'
ReviewService            = require '../../../lib/services/reviews'
ShippingMethodService    = require '../../../lib/services/shipping-methods'
StateService             = require '../../../lib/services/states'
TaxCategoryService       = require '../../../lib/services/tax-categories'
TypeService              = require '../../../lib/services/types'
ZoneService              = require '../../../lib/services/zones'

describe 'Service', ->

  ID = '1234-abcd-5678-efgh'
  KEY = 'key-key-key'

  _.each [
    {name: 'BaseService', service: BaseService, path: '', blacklist: ['byKey']}
    {name: 'CartDiscountService', service: CartDiscountService, path: '/cart-discounts', blacklist: ['byKey']}
    {name: 'CartService', service: CartService, path: '/carts', blacklist: ['byKey']}
    {name: 'CategoryService', service: CategoryService, path: '/categories', blacklist: ['byKey']}
    {name: 'ChannelService', service: ChannelService, path: '/channels', blacklist: ['byKey']}
    {name: 'CustomObjectService', service: CustomObjectService, path: '/custom-objects', blacklist: ['byKey']}
    {name: 'CustomerService', service: CustomerService, path: '/customers', blacklist: ['byKey']}
    {name: 'CustomerGroupService', service: CustomerGroupService, path: '/customer-groups', blacklist: ['byKey']}
    {name: 'DiscountCodeService', service: DiscountCodeService, path: '/discount-codes', blacklist: ['byKey']}
    {name: 'InventoryEntryService', service: InventoryEntryService, path: '/inventory', blacklist: ['byKey']}
    {name: 'MessageService', service: MessageService, path: '/messages', blacklist: ['byKey', 'save', 'create', 'update', 'delete']}
    {name: 'OrderService', service: OrderService, path: '/orders', blacklist: ['byKey', 'delete']}
    {name: 'PaymentService', service: PaymentService, path: '/payments', blacklist: ['byKey']}
    {name: 'ProductService', service: ProductService, path: '/products', blacklist: ['byKey']}
    {name: 'ProductDiscountService', service: ProductDiscountService, path: '/product-discounts', blacklist: ['byKey']}
    {name: 'ProductProjectionService', service: ProductProjectionService, path: '/product-projections', blacklist: ['byKey', 'save', 'create', 'update', 'delete']}
    {name: 'ProductTypeService', service: ProductTypeService, path: '/product-types', blacklist: []}
    {name: 'ProjectService', service: ProjectService, path: '', blacklist: ['byKey', 'save', 'create', 'update', 'delete']}
    {name: 'ReviewService', service: ReviewService, path: '/reviews', blacklist: ['byKey', 'delete']}
    {name: 'ShippingMethodService', service: ShippingMethodService, path: '/shipping-methods', blacklist: ['byKey']}
    {name: 'StateService', service: StateService, path: '/states', blacklist: ['byKey']}
    {name: 'TaxCategoryService', service: TaxCategoryService, path: '/tax-categories', blacklist: ['byKey']}
    {name: 'TypeService', service: TypeService, path: '/types', blacklist: []}
    {name: 'ZoneService', service: ZoneService, path: '/zones', blacklist: ['byKey']}
  ], (o) ->

    describe ":: #{o.name}", ->

      beforeEach ->
        @restMock =
          config: {}
          GET: (endpoint, callback) ->
          POST: -> (endpoint, payload, callback) ->
          PUT: ->
          DELETE: -> (endpoint, callback) ->
          PAGED: -> (endpoint, callback) ->
          _preRequest: ->
          _doRequest: ->
        @task = new TaskQueue
        @service = new o.service
          _rest: @restMock,
          _task: @task
          _stats:
            includeHeaders: false
            maskSensitiveHeaderData: false

      afterEach ->
        @service = null
        @restMock = null
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
        expect(@service._params.query.where).toEqual []
        expect(@service._params.query.operator).toBe 'and'
        expect(@service._params.query.sort).toEqual []
        expect(@service._params.query.expand).toEqual []

      it 'should build endpoint with id', ->
        @service.byId(ID)
        expect(@service._currentEndpoint).toBe "#{o.path}/#{ID}"

      it 'should throw if endpoint is already built with key', ->
        expect(=> @service.byKey(KEY).byId(ID)).toThrow()

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
          expect(promise.isPending()).toBe true

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

      it 'should set flag for \'all\'', ->
        @service.all()
        expect(@service._fetchAll).toBe(true)

      it 'should build query string', ->
        queryString = @service
          .where 'name(en = "Foo")'
          .where 'id = "1234567890"'
          .whereOperator 'or'
          .page 3
          .perPage 25
          .sort 'attrib', false
          .sort 'createdAt'
          .expand 'lineItems[*].state[*].state'
          ._queryString()

        expect(queryString).toBe 'where=name(en%20%3D%20%22Foo%22)%20or%20id%20%3D%20%221234567890%22&limit=25&offset=50&sort=attrib%20desc&sort=createdAt%20asc&expand=lineItems%5B*%5D.state%5B*%5D.state'

      it 'should use given queryString, when building it', ->
        queryString = @service
        .where 'name(en = "Foo")'
        .perPage 25
        .expand 'lineItems[*].state[*].state'
        .byQueryString('foo=bar')._queryString()
        expect(queryString).toBe 'foo=bar'

      it 'should set queryString, if given', ->
        @service.byQueryString('where=name(en = "Foo")&limit=10&staged=true&sort=name asc&expand=foo.bar1&expand=foo.bar2')
        expect(@service._params.queryString).toEqual 'where=name(en%20%3D%20%22Foo%22)&limit=10&staged=true&sort=name%20asc&expand=foo.bar1&expand=foo.bar2'

      it 'should set queryString, if given (already encoding)', ->
        @service.byQueryString('where=name(en%20%3D%20%22Foo%22)&limit=10&staged=true&sort=name%20asc&expand=foo.bar1&expand=foo.bar2', true)
        expect(@service._params.queryString).toEqual 'where=name(en%20%3D%20%22Foo%22)&limit=10&staged=true&sort=name%20asc&expand=foo.bar1&expand=foo.bar2'

      it 'should not use PAGED request when queryString is set', ->
        spyOn(@restMock, 'PAGED')
        spyOn(@restMock, 'GET')
        @service.byQueryString('limit=10').all().fetch()
        expect(@restMock.PAGED).not.toHaveBeenCalled()
        expect(@restMock.GET).toHaveBeenCalledWith "#{o.path}?limit=10", jasmine.any(Function)

      _.each [
        ['fetch']
        ['save', {foo: 'bar'}]
        ['delete', 2]
      ], (f) ->
        if not _.contains(o.blacklist, f[0])
          it "should reset params after creating a promise for #{f[0]}", ->
            _service = @service.byId('123-abc').where('name = "foo"').page(2).perPage(10).sort('id').expand('foo.bar')
            expect(@service._params.id).toBe '123-abc'
            expect(@service._params.query.where).toEqual [encodeURIComponent('name = "foo"')]
            expect(@service._params.query.operator).toBe 'and'
            expect(@service._params.query.sort).toEqual [encodeURIComponent('id asc')]
            expect(@service._params.query.page).toBe 2
            expect(@service._params.query.perPage).toBe 10
            expect(@service._params.query.expand).toEqual [encodeURIComponent('foo.bar')]
            if f[1]
              _service[f[0]](f[1])
            else
              _service[f[0]]()
            expect(@service._params.query.where).toEqual []
            expect(@service._params.query.operator).toBe 'and'
            expect(@service._params.query.sort).toEqual []
            expect(@service._params.query.expand).toEqual []

      if not _.contains(o.blacklist, 'byKey')

        it 'should build endpoint with key', ->
          @service.byKey(KEY)
          expect(@service._currentEndpoint).toBe "#{o.path}/key=#{KEY}"

        it 'should throw if endpoint is already built with id', ->
          expect(=> @service.byId(ID).byKey(KEY)).toThrow()

      if not _.contains(o.blacklist, 'save')

        it 'should censor authorization headers in case of a timeout', (done) ->
          spyOn(@service._rest, 'POST').andCallFake (endpoint, payload, callback) ->
            callback new Error('timeout'), null, null
          @service._rest._options =
            headers:
              Authorization: 'Bearer 9y1cbq8y34cnq9yap8enxrfgyqp934ncgp9'
          @service._stats.maskSensitiveHeaderData = true
          @service._stats.includeHeaders = true
          @service.save({foo: 'bar'})
          .then -> done('Should not happen')
          .catch (error) ->
            expect(error.body).toEqual
              message: 'timeout'
              originalRequest:
                options:
                  headers:
                    Authorization: 'Bearer **********'
                endpoint: o.path
                payload:
                  foo: 'bar'
            done()
          .done()

        it 'should censor authorization headers', (done) ->
          spyOn(@service._rest, 'POST').andCallFake (endpoint, payload, callback) ->
            callback null, {
              statusCode: 400,
              req: {
                _header: 'Authorization: Bearer 9y1cbq8y34cnq9yap8enxrfgyqp934ncgp9'
              },
              request: {
                headers: {
                  Authorization: 'Bearer 9y1cbq8y34cnq9yap8enxrfgyqp934ncgp9'
                }
              },
              headers: {
                Authorization: 'Bearer 9y1cbq8y34cnq9yap8enxrfgyqp934ncgp9'
              }
            }, {statusCode: 400, message: 'Oops, something went wrong'}
          @service._rest._options =
            headers:
              Authorization: 'Bearer 9y1cbq8y34cnq9yap8enxrfgyqp934ncgp9'
          @service._stats.maskSensitiveHeaderData = true
          @service._stats.includeHeaders = true
          @service.save({foo: 'bar'})
          .then -> done('Should not happen')
          .catch (error) ->
            expect(error.name).toBe 'BadRequest'
            expect(error.body).toEqual
              http:
                request:
                  method: undefined
                  httpVersion: undefined
                  uri: undefined
                  header: 'Authorization: Bearer **********'
                  headers:
                    Authorization: 'Bearer **********'
                response:
                  headers:
                    Authorization: 'Bearer **********'
              statusCode: 400
              message: 'Oops, something went wrong'
              originalRequest:
                options:
                  headers:
                    Authorization: 'Bearer **********'
                endpoint: o.path
                payload:
                  foo: 'bar'
            done()
          .done()

        it 'should pass original request to failed response', (done) ->
          spyOn(@service._rest, 'POST').andCallFake (endpoint, payload, callback) ->
            callback null, {statusCode: 400}, {statusCode: 400, message: 'Oops, something went wrong'}
          @service.save({foo: 'bar'})
          .then -> done('Should not happen')
          .catch (error) ->
            expect(error.name).toBe 'BadRequest'
            expect(error.body).toEqual
              statusCode: 400
              message: 'Oops, something went wrong'
              originalRequest:
                options: {}
                endpoint: o.path
                payload:
                  foo: 'bar'
            done()
          .done()

        it 'should pass headers info', (done) ->
          @service._stats.includeHeaders = true
          spyOn(@service._rest, 'POST').andCallFake (endpoint, payload, callback) ->
            callback null,
              statusCode: 200
              httpVersion: '1.1'
              request:
                method: 'POST'
                uri: {}
                headers: {}
              req:
                _header: 'POST /foo HTTP/1.1'
              headers: {}
            , {foo: 'bar'}
          @service.save({foo: 'bar'})
          .then (result) ->
            expect(result).toEqual
              http:
                request:
                  method: 'POST'
                  httpVersion: '1.1'
                  uri: {}
                  header: 'POST /foo HTTP/1.1'
                  headers: {}
                response:
                  headers: {}
              statusCode: 200
              body:
                foo: 'bar'
            done()
          .catch (error) -> done(_.prettify(error))
          .done()

      describe ':: process', ->
        it 'should return promise', ->
          promise = @service.process( -> )
          expect(promise.isPending()).toBe true

        it 'should call process function for one page', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {
            count: 1
            offset: 0
            results: []
          })
          fn = (payload) -> Promise.resolve 'done'
          @service.process(fn)
          .then (result) ->
            expect(result).toEqual ['done']
            done()
          .catch (error) -> done(_.prettify(error))

        it 'should call process function for several pages (default sorting)', (done) ->
          offset = -20
          count = 20
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) ->
            offset += 20
            callback(null, {statusCode: 200}, {
              # total: 50
              count: if offset is 40 then 10 else count
              offset: offset
              results: _.map (if offset is 40 then [1..10] else [1..20]), (i) -> {id: "id_#{i}", endpoint}

            })
          fn = (payload) ->
            Promise.resolve payload.body.results[0]
          @service.page(3).perPage(count).process(fn)
          .then (result) ->
            expect(_.size result).toBe 3
            expect(result[0].endpoint).toMatch /\?limit=20&offset=40&sort=id%20asc&withTotal=false$/
            expect(result[1].endpoint).toMatch /\?limit=20&offset=40&sort=id%20asc&withTotal=false&where=id%20%3E%20%22id_20%22$/
            expect(result[2].endpoint).toMatch /\?limit=20&offset=40&sort=id%20asc&withTotal=false&where=id%20%3E%20%22id_20%22$/
            done()
          .catch (error) -> done(_.prettify(error))

        it 'should call process function for several pages (given sorting)', (done) ->
          offset = -20
          count = 20
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) ->
            offset += 20
            callback(null, {statusCode: 200}, {
              # total: 50
              count: if offset is 40 then 10 else count
              offset: offset
              results: _.map (if offset is 40 then [1..10] else [1..20]), (i) -> {id: "id_#{i}", endpoint}
            })
          fn = (payload) ->
            Promise.resolve payload.body.results[0]
          @service.page(3).perPage(count).sort('foo').process(fn)
          .then (result) ->
            expect(_.size result).toBe 3
            expect(result[0].endpoint).toMatch /\?limit=20&offset=40&sort=foo%20asc&withTotal=false$/
            expect(result[1].endpoint).toMatch /\?limit=20&offset=40&sort=foo%20asc&withTotal=false&where=id%20%3E%20%22id_20%22$/
            expect(result[2].endpoint).toMatch /\?limit=20&offset=40&sort=foo%20asc&withTotal=false&where=id%20%3E%20%22id_20%22$/
            done()
          .catch (error) -> done(_.prettify(error))

        it 'should fail if the process functions rejects', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 100})
          fn = (payload) ->
            Promise.reject 'bad luck'
          @service.process(fn)
          .then (result) -> done 'not expected!'
          .catch (error) ->
            expect(error).toBe 'bad luck'
            done()

        it 'should call each page with the same query', (done) ->
          offset = -20
          count = 20
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) ->
            offset += 20
            callback(null, {statusCode: 200}, {
              # total: 50
              count: if offset is 40 then 10 else count
              offset: offset
              results: _.map (if offset is 40 then [1..10] else [1..20]), (i) -> {id: "id_#{i}", endpoint}
            })
          fn = (payload) ->
            Promise.resolve payload.body.results[0]
          @service.sort('name', false)
          .where('foo=bar')
          .where('hello=world')
          .whereOperator('or')
          .process(fn)
          .then (result) ->
            expect(_.size result).toBe 3
            expect(result[0].endpoint).toMatch /\?sort=name%20desc&withTotal=false&where=foo%3Dbar%20or%20hello%3Dworld$/
            expect(result[1].endpoint).toMatch /\?sort=name%20desc&withTotal=false&where=foo%3Dbar%20or%20hello%3Dworld%20and%20id%20%3E%20%22id_20%22$/
            expect(result[2].endpoint).toMatch /\?sort=name%20desc&withTotal=false&where=foo%3Dbar%20or%20hello%3Dworld%20and%20id%20%3E%20%22id_20%22$/
            done()
          .catch (error) -> done(_.prettify(error))

        it 'should throw error if function is missing', ->
          spyOn(@restMock, 'GET')
          expect(=> @service.process()).toThrow new Error 'Please provide a function to process the elements'
          expect(@restMock.GET).not.toHaveBeenCalled()

        it 'should set the limit to 20 if it is 0', ->
          spyOn(@restMock, 'GET')

          @service._params.query.perPage = 0

          fn = (payload) ->
            Promise.resolve payload.body.results[0]

          @service.process(fn)
          .then () ->

            actual = @service._params.query.limit
            expected = 20

            expect(actual).toEqual(expected)
            done()
          .catch (error) -> done(_.prettify(error))

        it 'should not accumulate results if explicitly set', (done) ->
          offset = -20
          count = 1
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) ->
            offset += 20
            callback(null, {statusCode: 200}, {
              # total: 50
              count: if offset is 40 then 0 else count
              offset: offset
              results: if offset is 40 then [] else [{id: '123', endpoint}]
            })
          fn = (payload) ->
            Promise.resolve payload.body.results[0]
          @service.perPage(1).process(fn, accumulate: false)
          .then (result) ->
            expect(result).toEqual []
            done()
          .catch (error) -> done(_.prettify(error))

      describe ':: fetch', ->

        it 'should return promise on fetch', ->
          promise = @service.fetch()
          expect(promise.isPending()).toBe true

        it 'should resolve the promise on fetch', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
          @service.fetch().then (result) ->
            expect(result.statusCode).toBe 200
            expect(result.body).toEqual foo: 'bar'
            done()
          .catch (error) -> done(_.prettify(error))

        it 'should reject the promise on fetch (404)', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
          @service.fetch()
          .then (result) -> done('Should not happen')
          .catch (error) ->
            expect(error.name).toBe 'NotFound'
            expect(error.body).toEqual
              statusCode: 404
              message: "Endpoint '/foo' not found."
              originalRequest:
                options: {}
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
          .catch (error) ->
            expect(error.name).toBe 'NotFound'
            expect(error.body).toEqual
              statusCode: 404
              message: "Endpoint '/foo' not found."
              originalRequest:
                options: {}
                endpoint: o.path
            done()

        it 'should reject the promise on fetch', (done) ->
          spyOn(@restMock, 'GET').andCallFake (endpoint, callback) -> callback('foo', null, null)
          @service.fetch()
          .then (result) -> done('Should not happen')
          .catch (error) ->
            expect(error.name).toBe 'HttpError'
            expect(error.body).toEqual
              message: 'foo'
              originalRequest:
                options: {}
                endpoint: o.path
            done()

        it 'should send request with id, if provided', ->
          spyOn(@restMock, 'GET')
          @service.byId(ID).fetch()
          expect(@restMock.GET).toHaveBeenCalledWith "#{o.path}/#{ID}", jasmine.any(Function)

        it 'should not do a paged request if perPage is 0', ->
          spyOn(@restMock, 'PAGED')
          spyOn(@restMock, 'GET')
          @service.byId(ID).sort('createdAt', true).perPage(0).fetch()
          expect(@restMock.PAGED).not.toHaveBeenCalled()
          expect(@restMock.GET).toHaveBeenCalledWith "#{o.path}/#{ID}?limit=0&sort=createdAt%20asc", jasmine.any(Function)

        it 'should do a paged request if all() was used before fetch', ->
          spyOn(@restMock, 'PAGED')
          spyOn(@restMock, 'GET')
          @service.byId(ID).sort('createdAt', true).all().fetch()
          expect(@restMock.PAGED).toHaveBeenCalledWith "#{o.path}/#{ID}?sort=createdAt%20asc", jasmine.any(Function)
          expect(@restMock.GET).not.toHaveBeenCalled()

        describe ':: paged', ->

          it 'should resolve the promise on (paged) fetch', (done) ->
            spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {total: 1, results: [{foo: 'bar'}]})
            @service.all().fetch()
            .then (result) ->
              expect(result.statusCode).toBe 200
              expect(result.body.total).toBe 1
              expect(result.body.results.length).toBe 1
              expect(result.body.results[0]).toEqual foo: 'bar'
              done()
            .catch (error) -> done(_.prettify(error))

          it 'should reject the promise on (paged) fetch (404)', (done) ->
            spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
            @service.all().fetch()
            .then (result) -> done('Should not happen')
            .catch (error) ->
              expect(error.name).toBe 'NotFound'
              expect(error.body).toEqual
                statusCode: 404
                message: "Endpoint '/foo' not found."
                originalRequest:
                  options: {}
                  endpoint: "#{o.path}?sort=id%20asc"
              done()

          it 'should reject the promise on (paged) fetch', (done) ->
            spyOn(@restMock, 'PAGED').andCallFake (endpoint, callback) -> callback('foo', null, null)
            @service.all().fetch()
            .then (result) -> done('Should not happen')
            .catch (error) ->
              expect(error.name).toBe 'HttpError'
              expect(error.body).toEqual
                message: 'foo'
                originalRequest:
                  options: {}
                  endpoint: "#{o.path}?sort=id%20asc"
              done()

          it 'should set default sorting if not provided (fetching all)', ->
            spyOn(@service, '_paged')
            @service.all().fetch()
            expect(@service._paged).toHaveBeenCalledWith "#{o.path}?sort=id%20asc"

          it 'should not set default sorting if provided (fetching all)', ->
            spyOn(@service, '_paged')
            @service.all().sort('foo').fetch()
            expect(@service._paged).toHaveBeenCalledWith "#{o.path}?sort=foo%20asc"

      if not _.contains(o.blacklist, 'save')
        describe ':: save', ->

          it 'should return promise on save', ->
            promise = @service.save {foo: 'bar'}
            expect(promise.isPending()).toBe true

          it 'should resolve the promise on save', (done) ->
            spyOn(@restMock, 'POST').andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
            @service.save({foo: 'bar'}).then (result) ->
              expect(result.statusCode).toBe 200
              expect(result.body).toEqual foo: 'bar'
              done()
            .catch (error) -> done(_.prettify(error))

          it 'should reject the promise on save (404)', (done) ->
            spyOn(@restMock, 'POST').andCallFake (endpoint, payload, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
            @service.save({foo: 'bar'})
            .then (result) -> done('Should not happen')
            .catch (error) ->
              expect(error.name).toBe 'NotFound'
              expect(error.body).toEqual
                statusCode: 404
                message: "Endpoint '/foo' not found."
                originalRequest:
                  options: {}
                  endpoint: o.path
                  payload:
                    foo: 'bar'
              done()

          it 'should throw error if payload is missing', ->
            spyOn(@restMock, 'POST')
            expect(=> @service.save()).toThrow new Error "Body payload is required for creating a resource (endpoint: #{@service.constructor.baseResourceEndpoint})"
            expect(@restMock.POST).not.toHaveBeenCalled()

          it 'should reject the promise on save', (done) ->
            spyOn(@restMock, 'POST').andCallFake (endpoint, payload, callback) -> callback('foo', null, null)
            @service.save({foo: 'bar'})
            .then (result) -> done('Should not happen')
            .catch (error) ->
              expect(error.name).toBe 'HttpError'
              expect(error.body).toEqual
                message: 'foo'
                originalRequest:
                  options: {}
                  endpoint: o.path
                  payload:
                    foo: 'bar'
              done()

          it 'should send request for base endpoint', ->
            spyOn(@restMock, 'POST')
            @service.save({foo: 'bar'})
            expect(@restMock.POST).toHaveBeenCalledWith o.path, {foo: 'bar'}, jasmine.any(Function)

      if not _.contains(o.blacklist, 'create')
        describe ':: create', ->

          it 'should be an alias for \'save\'', ->
            spyOn(@service, 'save')
            @service.create foo: 'bar'
            expect(@service.save).toHaveBeenCalledWith foo: 'bar'

      if not _.contains(o.blacklist, 'update')
        describe ':: update', ->

          it 'should send request for current endpoint with Id', ->
            spyOn(@restMock, 'POST')
            @service.byId(ID).update({foo: 'bar'})
            expect(@restMock.POST).toHaveBeenCalledWith "#{o.path}/#{ID}", {foo: 'bar'}, jasmine.any(Function)

          if not _.contains(o.blacklist, 'byKey')

            it 'should send request for current endpoint with Key', ->
              spyOn(@restMock, 'POST')
              @service.byKey(KEY).update({foo: 'bar'})
              expect(@restMock.POST).toHaveBeenCalledWith "#{o.path}/key=#{KEY}", {foo: 'bar'}, jasmine.any(Function)

            it 'should throw error if id and key is missing', ->
              spyOn(@restMock, 'POST')
              expect(=> @service.update()).toThrow new Error "Missing resource id. You can set it by chaining '.byId(ID)' or '.byKey(KEY)'"
              expect(@restMock.POST).not.toHaveBeenCalled()

          else

            it 'should throw error if id is missing', ->
              spyOn(@restMock, 'POST')
              expect(=> @service.update()).toThrow new Error "Missing resource id. You can set it by chaining '.byId(ID)'"
              expect(@restMock.POST).not.toHaveBeenCalled()

          it 'should throw error if payload is missing', ->
            spyOn(@restMock, 'POST')
            expect(=> @service.byId(ID).update()).toThrow new Error "Body payload is required for updating a resource (endpoint: #{@service._currentEndpoint}/#{ID})"
            expect(@restMock.POST).not.toHaveBeenCalled()

          it 'should use correct endpoints when calling update and create', ->
            spyOn(@restMock, 'POST')
            @service.byId(ID).update({foo: 'bar1'})
            @service.create({foo: 'bar2'})
            @service.byId(ID).update({foo: 'bar3'})
            @service.create({foo: 'bar4'})
            expect(@restMock.POST.calls.length).toBe 4
            expect(@restMock.POST.calls[0].args[0]).toEqual "#{o.path}/#{ID}"
            expect(@restMock.POST.calls[0].args[1]).toEqual {foo: 'bar1'}
            expect(@restMock.POST.calls[1].args[0]).toEqual o.path
            expect(@restMock.POST.calls[1].args[1]).toEqual {foo: 'bar2'}
            expect(@restMock.POST.calls[2].args[0]).toEqual "#{o.path}/#{ID}"
            expect(@restMock.POST.calls[2].args[1]).toEqual {foo: 'bar3'}
            expect(@restMock.POST.calls[3].args[0]).toEqual o.path
            expect(@restMock.POST.calls[3].args[1]).toEqual {foo: 'bar4'}

      if not _.contains(o.blacklist, 'delete')
        describe ':: delete', ->

          it 'should throw error if version is missing', ->
            spyOn(@restMock, 'DELETE')
            expect(=> @service.delete()).toThrow new Error "Version is required for deleting a resource (endpoint: #{@service._currentEndpoint})"
            expect(@restMock.DELETE).not.toHaveBeenCalled()

          it 'should return promise on delete', ->
            promise = @service.byId('123-abc').delete(1)
            expect(promise.isPending()).toBe true

          it 'should resolve the promise on delete', (done) ->
            spyOn(@restMock, 'DELETE').andCallFake (endpoint, callback) -> callback(null, {statusCode: 200}, {foo: 'bar'})
            @service.byId('123-abc').delete(1).then (result) ->
              expect(result.statusCode).toBe 200
              expect(result.body).toEqual foo: 'bar'
              done()
            .catch (error) -> done(_.prettify(error))

          it 'should reject the promise on delete (404)', (done) ->
            spyOn(@restMock, 'DELETE').andCallFake (endpoint, callback) -> callback(null, {statusCode: 404, request: {uri: {path: '/foo'}}}, null)
            @service.byId('123-abc').delete(1)
            .then (result) -> done('Should not happen')
            .catch (error) ->
              expect(error.name).toBe 'NotFound'
              expect(error.body).toEqual
                statusCode: 404
                message: "Endpoint '/foo' not found."
                originalRequest:
                  options: {}
                  endpoint: "#{o.path}/123-abc?version=1"
              done()

          it 'should reject the promise on delete', (done) ->
            spyOn(@restMock, 'DELETE').andCallFake (endpoint, callback) -> callback('foo', null, null)
            @service.byId('123-abc').delete(1)
            .then (result) -> done('Should not happen')
            .catch (error) ->
              expect(error.name).toBe 'HttpError'
              expect(error.body).toEqual
                message: 'foo'
                originalRequest:
                  options: {}
                  endpoint: "#{o.path}/123-abc?version=1"
              done()
