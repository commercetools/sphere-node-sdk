import expect from 'expect'
import https from 'https'
import SphereClient from '../lib'

const SERVICES = [
  'categories',
  'productProjections',
  'productProjectionsSearch',
  'products',
  'productTypes'
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
    const { options, queue } = client.productProjections
    expect(queue).toBeAn(Object)
    expect(options.Promise).toBeAn(Object)
    expect(options.auth.accessToken).toNotExist()
    expect(options.auth.credentials).toEqual({})
    expect(options.auth.shouldRetrieveToken).toBeA('function')
    expect(options.request).toEqual({
      agent: undefined,
      headers: { 'User-Agent': 'sphere-node-sdk-2.0' },
      host: 'api.sphere.io',
      maxParallel: 20,
      protocol: 'https',
      timeout: 20000,
      urlPrefix: undefined
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
    const shouldRetrieveToken = cb => cb(false)

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
      },
      httpMock: null
    })
  })

  it('should ensure service instance is not shared', () => {
    const client1 = SphereClient.create({})
    const productProjectionsService1 = client1.productProjections
    expect(productProjectionsService1.byId('123').params.id).toEqual('123')

    const client2 = SphereClient.create({})
    const productProjectionsService2 = client2.productProjections
    expect(productProjectionsService2).toExist()
    expect(productProjectionsService2.params.id).toNotEqual('123')
  })

  it('should register a new service', () => {
    const client = SphereClient.create({})
    const serviceConfig = {
      type: 'my-new-service',
      endpoint: '/my-service-endpoint',
      options: {
        hasRead: true,
        hasCreate: true,
        hasUpdate: false,
        hasDelete: true,
        hasQuery: true,
        hasQueryOne: true,
        hasSearch: false,
        hasProjection: false
      }
    }
    const headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer qwertzuiopasdfghjkl'
    }
    client.registerService('myNewService', serviceConfig, { headers })

    expect(client.myNewService).toExist()
    expect(client.myNewService.baseEndpoint).toBe('/my-service-endpoint')
    expect(client.myNewService.update).toNotExist()
    expect(client.myNewService.staged).toNotExist()
  })

  it('should replace http client', () => {
    const client = SphereClient.create({})
    client.replaceHttpClient('foo')

    expect(client.products.options.httpMock).toBe('foo')
  })
})
