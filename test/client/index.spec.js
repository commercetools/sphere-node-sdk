import { SphereClient } from '../../lib'

describe('SphereClient', () => {

  it('should initialize client (as class)', () => {
    const client = new SphereClient({})
    const productProjectionsService = client.productProjections
    expect(productProjectionsService).toBeDefined()
  })

  it('should initialize client (as factory)', () => {
    const client = SphereClient.create({})
    const productProjectionsService = client.productProjections
    expect(productProjectionsService).toBeDefined()
  })

  it('should inject data into service', () => {
    const client = new SphereClient({})
    const productProjectionsService = client.productProjections
    expect(productProjectionsService.request).toBeDefined()
    expect(productProjectionsService.options).toEqual({
      request: {
        host: 'https://api.sphere.io'
      }
    })
  })

  it('should ensure service instance is not shared', () => {
    const client1 = new SphereClient({})
    const productProjectionsService1 = client1.productProjections
    expect(productProjectionsService1.byId('123').params.id).toBe('123')

    const client2 = new SphereClient({})
    const productProjectionsService2 = client2.productProjections
    expect(productProjectionsService2).toBeDefined()
    expect(productProjectionsService2.params.id).not.toBe('123')
  })
})
