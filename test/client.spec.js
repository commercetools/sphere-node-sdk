import test from 'tape'
import https from 'https'
import * as version from '../version'
import SphereClient from '../lib'

const { features } = SphereClient
const userAgent = `${version.name}-${version.version}`
const SERVICES = [
  // order matters!
  'categories',
  'channels',
  'customerGroups',
  'productProjections',
  'productProjectionsSearch',
  'products',
  'productTypes',
  'taxCategories',

  // keep as last!
  'graphql',
]

test('SphereClient', t => {
  t.test('should initialize client (as class)', t => {
    const client = new SphereClient({})
    t.deepEqual(Object.keys(client), SERVICES)
    t.end()
  })

  t.test('should initialize client (as factory)', t => {
    const client = SphereClient.create({})
    t.deepEqual(Object.keys(client), SERVICES)
    t.end()
  })

  t.test('should initialize with default options', t => {
    const client = SphereClient.create({})
    const { options, queue } = client.productProjections
    t.equal(typeof queue, 'object')
    t.equal(typeof options.Promise, 'function')
    t.false(options.auth.accessToken)
    t.deepEqual(options.auth.credentials, {})
    t.equal(typeof options.auth.shouldRetrieveToken, 'function')
    t.deepEqual(options.request, {
      agent: undefined,
      headers: { 'User-Agent': userAgent },
      host: 'api.sphere.io',
      maxParallel: 20,
      protocol: 'https',
      timeout: 20000,
      urlPrefix: undefined,
    })
    t.end()
  })

  t.test('should initialize with custom options', t => {
    const agent = new https.Agent({})
    const headers = {
      'Content-Type': 'application/json',
      Authorization: 'Bearer qwertzuiopasdfghjkl',
    }
    const timeout = 1000
    const urlPrefix = '/public'
    const maxParallel = 10
    const credentials = {
      projectKey: 'foo',
      clientId: '123',
      clientSecret: 'secret',
    }
    const shouldRetrieveToken = cb => cb(false)

    const client = SphereClient.create({
      Promise: { foo: 'bar' },
      auth: { credentials, shouldRetrieveToken },
      request: { agent, headers, maxParallel, timeout, urlPrefix },
    })
    t.deepEqual(client.productProjections.options, {
      Promise: { foo: 'bar' },
      auth: {
        accessToken: undefined,
        credentials,
        shouldRetrieveToken,
        host: 'auth.sphere.io',
      },
      request: {
        agent,
        headers,
        host: 'api.sphere.io',
        maxParallel,
        protocol: 'https',
        timeout,
        urlPrefix,
      },
      httpMock: undefined,
    })
    t.end()
  })

  t.test('should ensure service instance is not shared', t => {
    const client1 = SphereClient.create({})
    const productProjectionsService1 = client1.productProjections
    t.equal(productProjectionsService1.byId('123').params.id, '123')

    const client2 = SphereClient.create({})
    const productProjectionsService2 = client2.productProjections
    t.true(productProjectionsService2)
    t.notEqual(productProjectionsService2.params.id, '123')
    t.end()
  })

  t.test('should register a new service', t => {
    const client = SphereClient.create({})
    const serviceConfig = {
      type: 'my-new-service',
      endpoint: '/my-service-endpoint',
      features: [
        features.read,
        features.create,
        features.delete,
        features.query,
        features.queryOne,
      ],
    }
    const headers = {
      'Content-Type': 'application/json',
      Authorization: 'Bearer qwertzuiopasdfghjkl',
    }
    client.registerService('myNewService', serviceConfig, { headers })

    t.true(client.myNewService)
    t.equal(client.myNewService.baseEndpoint, '/my-service-endpoint')
    t.false(client.myNewService.update)
    t.false(client.myNewService.staged)
    t.end()
  })

  t.test('should replace http client', t => {
    const client = SphereClient.create({})
    client.replaceHttpClient('foo')

    t.equal(client.products.options.httpMock, 'foo')
    t.end()
  })
})
