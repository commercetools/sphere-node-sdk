import { productProjectionsFn } from '../../../lib/client/services'

describe('ProductProjections', () => {

  let mockDeps

  beforeEach(() => {
    mockDeps = {
      http: {
        get: jasmine.createSpy('get'),
        post: jasmine.createSpy('post'),
        delete: jasmine.createSpy('delete')
      },
      queue: {
        addTask: (fn) => fn()
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
    expect(service.baseEndpoint).toBe('/product-projections')
    expect(service.byId).toEqual(jasmine.any(Function))
    expect(service.where).toEqual(jasmine.any(Function))
    expect(service.fetch).toEqual(jasmine.any(Function))
  })

  it('should build default fetch url', () => {
    const service = productProjectionsFn(mockDeps)

    service.fetch()
    expect(mockDeps.http.get).toHaveBeenCalledWith(
      'https://api.sphere.io/foo/product-projections')
  })

  it('should build custom fetch url', () => {
    mockDeps.options.request.urlPrefix = '/public'
    const service = productProjectionsFn(mockDeps)

    service.byId('123').fetch()
    expect(mockDeps.http.get).toHaveBeenCalledWith(
      'https://api.sphere.io/public/foo/product-projections/123')
  })
})
