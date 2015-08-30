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

    service.byId('123').fetch()
    expect(spy).toHaveBeenCalledWith({
      'method': 'GET',
      'url': 'https://api.sphere.io/public/foo/product-projections/123'
    })
  })
})
