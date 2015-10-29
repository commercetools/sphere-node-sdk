import test from 'tape'
import sinon from 'sinon'
import * as verbs from '../../lib/utils/verbs'
import * as query from '../../lib/utils/query'
import * as queryId from '../../lib/utils/query-id'
import * as queryPage from '../../lib/utils/query-page'
import * as queryProjection from '../../lib/utils/query-projection'
import * as querySearch from '../../lib/utils/query-search'
import * as queryCustom from '../../lib/utils/query-custom'
import * as features from '../../lib/utils/features'
import { getDefaultQueryParams, getDefaultSearchParams }
  from '../../lib/utils/default-params'

const projectKey = 'test-project'
const baseEndpoint = '/test-endpoint'

test('Utils::verbs', t => {

  let mockService, spy

  function setup () {
    mockService = Object.assign({
      queue: {
        addTask: () => {}
      },
      options: {
        auth: {
          credentials: { projectKey }
        },
        request: {
          host: 'api.sphere.io',
          protocol: 'https'
        }
      },
      type: 'test-type',
      features: [],
      params: getDefaultQueryParams(),
      baseEndpoint
    }, query, queryId, queryPage, queryCustom, verbs)
    spy = sinon.spy(mockService.queue, 'addTask')
  }

  t.test('should build fetch url', t => {
    setup()

    mockService.fetch()
    t.deepEqual(spy.getCall(0).args[0], {
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}${baseEndpoint}`
    })
    t.end()
  })

  t.test('should build custom fetch url with prefix', t => {
    setup()

    mockService.options.request.urlPrefix = '/public'
    mockService.fetch()
    t.deepEqual(spy.getCall(0).args[0], {
      method: 'GET',
      url: `https://api.sphere.io/public/${projectKey}${baseEndpoint}`
    })
    t.end()
  })

  t.test('should build fetch url with query parameters', t => {
    setup()

    mockService.perPage(10).fetch()
    t.deepEqual(spy.getCall(0).args[0], {
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}${baseEndpoint}?limit=10`
    })
    t.end()
  })

  t.test('should build fetch url with custom query parameters', t => {
    setup()

    const encoded = encodeURIComponent('foo=bar&text="Hello world"')
    mockService.perPage(10).where('one=two').byQueryString(encoded).fetch()
    t.deepEqual(spy.getCall(0).args[0], {
      method: 'GET',
      url: `https://api.sphere.io/${projectKey}${baseEndpoint}?${encoded}`
    })
    t.end()
  })

  t.test('should reset params after building the request promise', t => {
    setup()

    Object.assign(mockService, {
      features: [ features.query, features.queryOne ]
    })
    const req = mockService.perPage(10).sort('createdAt', false)
    t.deepEqual(req.params, {
      id: null,
      customQuery: null,
      expand: [],
      query: {
        operator: 'and',
        where: []
      },
      pagination: {
        page: null,
        perPage: 10,
        sort: [encodeURIComponent('createdAt desc')]
      }
    })

    req.fetch()
    t.deepEqual(req.params, getDefaultQueryParams())
    t.end()
  })

  t.test('should build default create url', t => {
    setup()

    mockService.create({ foo: 'bar' })
    t.deepEqual(spy.getCall(0).args[0], {
      method: 'POST',
      url: `https://api.sphere.io/${projectKey}${baseEndpoint}`,
      body: { foo: 'bar' }
    })
    t.end()
  })

  t.test('should throw if body is missing (create)', t => {
    setup()

    t.throws(() => mockService.create(),
      /Body payload is required for creating a resource/)
    t.end()
  })

  t.test('should build default update url', t => {
    setup()

    mockService.byId('123').update({ foo: 'bar' })
    t.deepEqual(spy.getCall(0).args[0], {
      method: 'POST',
      url: `https://api.sphere.io/${projectKey}${baseEndpoint}/123`,
      body: { foo: 'bar' }
    })
    t.end()
  })

  t.test('should throw if body is missing (update)', t => {
    setup()

    t.throws(() => mockService.update(),
      /Body payload is required for updating a resource/)
    t.end()
  })

  t.test('should throw if resource id is missing (update)', t => {
    setup()

    t.throws(() => mockService.update({ foo: 'bar' }),
      /Missing required `id` param for updating a resource/)
    t.end()
  })

  t.test('should build default delete url', t => {
    setup()

    mockService.byId('123').delete(1)
    t.deepEqual(spy.getCall(0).args[0], {
      method: 'DELETE',
      url: `https://api.sphere.io/${projectKey}${baseEndpoint}/123?version=1`
    })
    t.end()
  })

  t.test('should throw if version is missing (delete)', t => {
    setup()

    t.throws(() => mockService.delete(),
      /Version number is required for deleting a resource/)
    t.end()
  })

  t.test('should throw if resource id is missing (delete)', t => {
    setup()

    t.throws(() => mockService.delete({ foo: 'bar' }),
      /Missing required `id` param for deleting a resource/)
    t.end()
  })

  t.test('product-projections', t => {

    t.test('should reset params after building the request promise', t => {
      setup()

      Object.assign(mockService, {
        features: [ features.query, features.queryOne, features.projection ]
      }, queryProjection)

      const req =
        mockService.staged(false).perPage(10).sort('createdAt', false)
      t.deepEqual(req.params, {
        id: null,
        customQuery: null,
        expand: [],
        staged: false,
        query: {
          operator: 'and',
          where: []
        },
        pagination: {
          page: null,
          perPage: 10,
          sort: [encodeURIComponent('createdAt desc')]
        }
      })

      req.fetch()
      t.deepEqual(req.params,
        Object.assign(getDefaultQueryParams(), { staged: true }))
      t.end()
    })
  })

  t.test('product-projections-search', t => {

    t.test('should reset params after building the request promise', t => {
      setup()

      Object.assign(mockService, {
        features: [ features.projection, features.search ],
        params: getDefaultSearchParams()
      }, queryProjection, querySearch)

      const req = mockService.staged(false)
        .text('Foo', 'en')
        .facet('variants.attributes.foo:"bar"')
        .filter('variants.sku:"foo123"')
        .filter('variants.attributes.color.key:"red"')
        .sort('createdAt', false)
      t.deepEqual(req.params, {
        staged: false,
        expand: [],
        pagination: {
          page: null,
          perPage: null,
          sort: [encodeURIComponent('createdAt desc')]
        },
        search: {
          facet: [encodeURIComponent('variants.attributes.foo:"bar"')],
          filter: [
            encodeURIComponent('variants.sku:"foo123"'),
            encodeURIComponent('variants.attributes.color.key:"red"')
          ],
          filterByQuery: [],
          filterByFacets: [],
          text: { lang: 'en', value: 'Foo' }
        }
      })

      req.fetch()
      t.deepEqual(req.params, getDefaultSearchParams())
      t.end()
    })
  })

})
