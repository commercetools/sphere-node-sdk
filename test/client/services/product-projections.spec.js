import { productProjectionsFn } from '../../../lib/client/services'

describe('ProductProjections', () => {

  it('should initialize client', () => {
    const service = productProjectionsFn()
    expect(service.baseEndpoint).toBe('/product-projections')
    expect(service.byId).toEqual(jasmine.any(Function))
    expect(service.where).toEqual(jasmine.any(Function))
    expect(service.fetch).toEqual(jasmine.any(Function))
  })

  it('should build fetch url', () => {
    const requestStub = jasmine.createSpy('request')
    const opts = {
      request: {
        host: 'https://api.sphere.io'
      }
    }
    const service = productProjectionsFn({
      request: requestStub,
      options: opts
    })

    service.fetch()
    expect(requestStub)
      .toHaveBeenCalledWith('https://api.sphere.io/product-projections')
  })
})
