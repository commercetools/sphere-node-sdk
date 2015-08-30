import expect from 'expect'
import { productProjectionsFn } from '../../../lib/client/services'

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
    expect(service.byId).toBeA('function')
    expect(service.where).toBeA('function')
    expect(service.fetch).toBeA('function')
  })

  it('should build default fetch url', () => {
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.fetch()
    expect(spy).toHaveBeenCalledWith({
      'method': 'GET',
      'url': 'https://api.sphere.io/foo/product-projections'
    })
  })

  it('should build custom fetch url with prefix', () => {
    mockDeps.options.request.urlPrefix = '/public'
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.fetch()
    expect(spy).toHaveBeenCalledWith({
      'method': 'GET',
      'url': 'https://api.sphere.io/public/foo/product-projections'
    })
  })

  it('should build fetch url with query parameters', () => {
    const service = productProjectionsFn(mockDeps)
    const spy = expect.spyOn(mockDeps.queue, 'addTask')

    service.perPage(10).fetch()
    expect(spy).toHaveBeenCalledWith({
      'method': 'GET',
      'url': 'https://api.sphere.io/foo/product-projections?limit=10'
    })
  })
})
