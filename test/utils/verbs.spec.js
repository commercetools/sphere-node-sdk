import expect from 'expect'
import * as verbs from '../../lib/utils/verbs'
import * as query from '../../lib/utils/query'
import * as queryId from '../../lib/utils/query-id'
import * as queryPage from '../../lib/utils/query-page'
import * as queryProjection from '../../lib/utils/query-projection'
import * as querySearch from '../../lib/utils/query-search'
import * as queryCustom from '../../lib/utils/query-custom'
import { getDefaultQueryParams, getDefaultSearchParams }
  from '../../lib/utils/default-params'

const projectKey = 'test-project'
const baseEndpoint = '/test-endpoint'

describe('Utils', () => {

  describe('::verbs', () => {

    let defaultServiceConfig, mockService, spy

    beforeEach(() => {
      defaultServiceConfig = {
        hasRead: false,
        hasCreate: false,
        hasUpdate: false,
        hasDelete: false,
        hasQuery: false,
        hasQueryOne: false,
        hasSearch: false,
        hasProjection: false
      },
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
        serviceConfig: defaultServiceConfig,
        params: getDefaultQueryParams(),
        baseEndpoint
      }, query, queryId, queryPage, queryCustom, verbs)
      spy = expect.spyOn(mockService.queue, 'addTask')
    })

    it('should build fetch url', () => {
      mockService.fetch()
      expect(spy).toHaveBeenCalledWith({
        method: 'GET',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}`
      })
    })

    it('should build custom fetch url with prefix', () => {
      mockService.options.request.urlPrefix = '/public'
      mockService.fetch()
      expect(spy).toHaveBeenCalledWith({
        method: 'GET',
        url: `https://api.sphere.io/public/${projectKey}${baseEndpoint}`
      })
    })

    it('should build fetch url with query parameters', () => {
      mockService.perPage(10).fetch()
      expect(spy).toHaveBeenCalledWith({
        method: 'GET',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}?limit=10`
      })
    })

    it('should build fetch url with custom query parameters', () => {
      const encoded = encodeURIComponent('foo=bar&text="Hello world"')
      mockService.perPage(10).where('one=two').byQueryString(encoded).fetch()
      expect(spy).toHaveBeenCalledWith({
        method: 'GET',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}?${encoded}`
      })
    })

    it('should reset params after building the request promise', () => {
      Object.assign(mockService, {
        serviceConfig: Object.assign({}, defaultServiceConfig, {
          hasQueryOne: true,
          hasQuery: true
        })
      })
      const req = mockService.perPage(10).sort('createdAt', false)
      expect(req.params).toEqual({
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
      expect(req.params).toEqual(getDefaultQueryParams())
    })

    it('should build default create url', () => {
      mockService.create({ foo: 'bar' })
      expect(spy).toHaveBeenCalledWith({
        method: 'POST',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}`,
        body: { foo: 'bar' }
      })
    })

    it('should throw if body is missing (create)', () => {
      expect(() => mockService.create())
      .toThrow(/Body payload is required for creating a resource/)
    })

    it('should build default update url', () => {
      mockService.byId('123').update({ foo: 'bar' })
      expect(spy).toHaveBeenCalledWith({
        method: 'POST',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}/123`,
        body: { foo: 'bar' }
      })
    })

    it('should throw if body is missing (update)', () => {
      expect(() => mockService.update())
      .toThrow(/Body payload is required for updating a resource/)
    })

    it('should throw if resource id is missing (update)', () => {
      expect(() => mockService.update({ foo: 'bar' }))
      .toThrow(/Missing required `id` param for updating a resource/)
    })

    it('should build default delete url', () => {
      mockService.byId('123').delete(1)
      expect(spy).toHaveBeenCalledWith({
        method: 'DELETE',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}/123?version=1`
      })
    })

    it('should throw if version is missing (delete)', () => {
      expect(() => mockService.delete())
      .toThrow(/Version number is required for deleting a resource/)
    })

    it('should throw if resource id is missing (delete)', () => {
      expect(() => mockService.delete({ foo: 'bar' }))
      .toThrow(/Missing required `id` param for deleting a resource/)
    })

    describe('product-projections', () => {

      it('should reset params after building the request promise', () => {
        Object.assign(mockService, {
          serviceConfig: Object.assign({}, defaultServiceConfig, {
            hasQueryOne: true,
            hasQuery: true,
            hasProjection: true
          })
        }, queryProjection)

        const req =
          mockService.staged(false).perPage(10).sort('createdAt', false)
        expect(req.params).toEqual({
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
        expect(req.params).toEqual(
          Object.assign(getDefaultQueryParams(), { staged: true }))
      })
    })

    describe('product-projections-search', () => {

      it('should reset params after building the request promise', () => {
        Object.assign(mockService, {
          serviceConfig: Object.assign({}, defaultServiceConfig, {
            hasProjection: true,
            hasSearch: true
          }),
          params: getDefaultSearchParams()
        }, queryProjection, querySearch)

        const req = mockService.staged(false)
          .text('Foo', 'en')
          .facet('variants.attributes.foo:"bar"')
          .filter('variants.sku:"foo123"')
          .filter('variants.attributes.color.key:"red"')
          .sort('createdAt', false)
        expect(req.params).toEqual({
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
        expect(req.params).toEqual(getDefaultSearchParams())
      })
    })

  })
})
