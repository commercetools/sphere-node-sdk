import expect from 'expect'
import * as verbs from '../../lib/utils/verbs'
import * as query from '../../lib/utils/query'
import * as queryId from '../../lib/utils/query-id'
import { getDefaultQueryParams } from '../../lib/utils/default-params'

const projectKey = 'test-project'
const baseEndpoint = '/test-endpoint'

describe('Utils', () => {

  describe('::verbs', () => {

    let mockService, spy

    beforeEach(() => {
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
        params: getDefaultQueryParams(),
        baseEndpoint
      }, query, queryId, verbs)
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

    it('should reset params after building the request promise', () => {
      const req = mockService.perPage(10).sort('createdAt', false)
      expect(req.params).toEqual({
        id: null,
        query: {
          expand: [],
          operator: 'and',
          page: null,
          perPage: 10,
          sort: [encodeURIComponent('createdAt desc')],
          where: []
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

    it('should build default update url', () => {
      mockService.byId('123').update({ foo: 'bar' })
      expect(spy).toHaveBeenCalledWith({
        method: 'POST',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}/123`,
        body: { foo: 'bar' }
      })
    })

    it('should build default delete url', () => {
      mockService.byId('123').delete(1)
      expect(spy).toHaveBeenCalledWith({
        method: 'DELETE',
        url: `https://api.sphere.io/${projectKey}${baseEndpoint}/123?version=1`
      })
    })

  })
})
