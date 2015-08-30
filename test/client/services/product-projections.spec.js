import expect from 'expect'
import { productProjectionsFn } from '../../../lib/client/services'
import { getDefaultQueryParams }
  from '../../../lib/client/services/commons/default-params'

describe('ProductProjections', () => {

  let mockDeps

  beforeEach(() => {
    mockDeps = {
      queue: {
        addTask: () => {}
      },
      options: {
        auth: {
          credentials: {
            projectKey: 'foo'
          }
        },
        request: {
          host: 'api.sphere.io',
          protocol: 'https'
        }
      }
    }
  })

  it('should initialize service', () => {
    const service = productProjectionsFn(mockDeps)
    expect(service.baseEndpoint).toEqual('/product-projections')
  })

  it('should build default fetch url', () => {
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.fetch()
    expect(spy).toHaveBeenCalledWith({
      method: 'GET',
      url: 'https://api.sphere.io/foo/product-projections'
    })
  })

  it('should build custom fetch url with prefix', () => {
    mockDeps.options.request.urlPrefix = '/public'
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.fetch()
    expect(spy).toHaveBeenCalledWith({
      method: 'GET',
      url: 'https://api.sphere.io/public/foo/product-projections'
    })
  })

  it('should build fetch url with query parameters', () => {
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.perPage(10).fetch()
    expect(spy).toHaveBeenCalledWith({
      method: 'GET',
      url: 'https://api.sphere.io/foo/product-projections?limit=10'
    })
  })

  it('should reset params after building the request promise', () => {
    const service = productProjectionsFn(mockDeps)

    const req = service.perPage(10).sort('createdAt', false)
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
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.create({ foo: 'bar' })
    expect(spy).toHaveBeenCalledWith({
      method: 'POST',
      url: 'https://api.sphere.io/foo/product-projections',
      body: { foo: 'bar' }
    })
  })

  it('should build default update url', () => {
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.byId('123').update({ foo: 'bar' })
    expect(spy).toHaveBeenCalledWith({
      method: 'POST',
      url: 'https://api.sphere.io/foo/product-projections/123',
      body: { foo: 'bar' }
    })
  })

  it('should build default delete url', () => {
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.byId('123').delete(1)
    expect(spy).toHaveBeenCalledWith({
      method: 'DELETE',
      url: 'https://api.sphere.io/foo/product-projections/123?version=1'
    })
  })
})
