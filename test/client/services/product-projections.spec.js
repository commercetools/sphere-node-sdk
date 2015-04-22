import { productProjections } from '../../../lib/client/services'

describe('ProductProjections', () => {

  it('should initialize client', () => {
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
