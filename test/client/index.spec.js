import { SphereClient } from '../../lib'

describe('SphereClient', () => {

  it('should initialize client', () => {
    const client = SphereClient({})
    const productProjectionsService = client.productProjections
    expect(productProjectionsService).toBeDefined()
    expect(productProjectionsService.byId('123').id).toBe('123')
  })
})
