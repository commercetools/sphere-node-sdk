import https from 'https'
import { SphereClient } from '../../lib'

const SERVICES = [
  'productProjections'
]

describe('SphereClient', () => {

  it('should initialize client (as class)', () => {
    const client = new SphereClient({})
    expect(Object.keys(client)).toEqual(SERVICES)
  })

  it('should initialize client (as factory)', () => {
    const client = SphereClient.create({})
    expect(Object.keys(client)).toEqual(SERVICES)
  })

  it('should initialize with default options', () => {
    const client = SphereClient.create({})
    expect(client.productProjections.http).toEqual(jasmine.any(Object))
    expect(client.productProjections.options).toEqual({
      Promise: Promise,
      auth: {
        accessToken: undefined,
        credentials: undefined,
        shouldRetrieveToken: jasmine.any(Function)
      },
      request: {
        agent: undefined,
        headers: {},
        host: 'api.sphere.io',
        maxParallel: 20,
        protocol: 'https',
        timeout: 20000,
        urlPrefix: undefined
      }
    })
  })

  it('should initialize with custom options', () => {
    const agent = new https.Agent({})
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer qwertzuiopasdfghjkl'
    }
    const timeout = 1000
    const urlPrefix = '/public'
    const maxParallel = 10
    const credentials = {
      projectKey: 'foo',
      clientId: '123',
      clientSecret: 'secret'
    }
    const shouldRetrieveToken = cb => { cb(false) }

    const client = SphereClient.create({
      Promise: { foo: 'bar' },
      auth: { credentials, shouldRetrieveToken },
      request: { agent, headers, maxParallel, timeout, urlPrefix }
    })
    expect(client.productProjections.options).toEqual({
      Promise: { foo: 'bar' },
      auth: { accessToken: undefined, credentials, shouldRetrieveToken },
      request: {
        agent,
        headers,
        host: 'api.sphere.io',
        maxParallel,
        protocol: 'https',
        timeout,
        urlPrefix
      }
    })
  })

  it('should ensure service instance is not shared', () => {
    const client1 = SphereClient.create({})
    const productProjectionsService1 = client1.productProjections
    expect(productProjectionsService1.byId('123').params.id).toBe('123')

    const client2 = SphereClient.create({})
    const productProjectionsService2 = client2.productProjections
    expect(productProjectionsService2).toBeDefined()
    expect(productProjectionsService2.params.id).not.toBe('123')
  })
})
