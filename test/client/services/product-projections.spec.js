import { productProjections } from '../../../lib/client/services'

describe('ProductProjections', () => {

  it('should initialize client', () => {
    expect(productProjections.baseEndpoint).toBe('/product-projections')
    expect(productProjections.byId).toEqual(jasmine.any(Function))
    expect(productProjections.where).toEqual(jasmine.any(Function))
    expect(productProjections.fetch).toEqual(jasmine.any(Function))
  })

  it('should build fetch url', () => {
    const requestStub = jasmine.createSpy('request')
    const opts = {
      request: {
        host: 'https://api.sphere.io'
      }
    }
    const service = Object.assign({}, productProjections)
    service.request = requestStub
    service.options = opts

    service.fetch()
    expect(requestStub)
      .toHaveBeenCalledWith('https://api.sphere.io/product-projections')
  })
})
