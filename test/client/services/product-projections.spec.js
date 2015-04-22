import { productProjectionsFn } from '../../../lib/client/services'

describe('ProductProjections', () => {

  it('should initialize client', () => {
    const requestStub = jasmine.createSpy('request')
    const opts = {
      request: {
        host: 'https://api.sphere.io'
      }
    }
    const productProjectionsService = productProjectionsFn(requestStub, opts)
    productProjectionsService.fetch()
    expect(requestStub)
      .toHaveBeenCalledWith('https://api.sphere.io/product-projections')
  })
})
