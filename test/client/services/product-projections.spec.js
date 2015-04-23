import { productProjectionsFn } from '../../../lib/client/services'

describe('ProductProjections', () => {

  let mockDeps

  beforeEach(() => {
    mockDeps = {
      request: jasmine.createSpy('request'),
      options: {
        request: {
          host: 'https://api.sphere.io'
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

  Array.prototype.forEach.call(
    ['request', 'options']
  , key => {
    it(`should freeze property '${key}' and make it non-enumerable`, () => {
      const service = productProjectionsFn(mockDeps)
      expect(Object.keys(service)).not.toContain(key)
      expect(Object.getOwnPropertyNames(service)).toContain(key)
      expect(service[key]).toBeDefined()
    })
  })

  it('should build fetch url', () => {
    const service = productProjectionsFn(mockDeps)

    service.fetch()
    expect(mockDeps.request)
      .toHaveBeenCalledWith('https://api.sphere.io/product-projections')
  })
})
