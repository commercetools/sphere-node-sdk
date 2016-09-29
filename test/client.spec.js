import test from 'tape'
import SphereClient from '../src'

const {
  FEATURE_READ,
  FEATURE_CREATE,
  FEATURE_DELETE,
  FEATURE_QUERY,
  FEATURE_QUERY_ONE,

  SERVICE_INIT,
} = SphereClient.constants

const registeredServices = [
  // order matters!
  'categories',
  'channels',
  'customer-groups',
  'product-projections',
  'product-projections-search',
  'product-types',
  'products',
  'tax-categories',

  // keep as last!
  'graphql',
]

const fakeMiddleware = () => next => action => next(action)

function getTestOptions (options) {
  return {
    promiseLibrary: Promise,
    projectKey: 'test',
    oauth: {
      token: undefined,
      expiresIn: undefined,
    },
    middlewares: [
      fakeMiddleware,
    ],

    ...options,
  }
}

test('SphereClient', (t) => {
  t.test('should initialize client', (t) => {
    const clientOptions = getTestOptions()

    t.comment('as Class')
    const clientAsClass = new SphereClient(clientOptions)
    t.deepEqual(Object.keys(clientAsClass),
      [
        'getService',
        'registerService',
        'listServices',
      ],
      'expose only getters / setters as client API'
    )

    t.comment('as factory function')
    const clientAsFactory = new SphereClient(clientOptions)
    t.deepEqual(Object.keys(clientAsFactory),
      [
        'getService',
        'registerService',
        'listServices',
      ],
      'expose only getters / setters as client API'
    )

    t.end()
  })

  t.test('should throw if no middleware is defined', (t) => {
    t.throws(
      () => {
        SphereClient.create({})
      },
      /No middlewares found/,
      'throw if no middleware is found'
    )
    t.end()
  })

  t.test('should get services', (t) => {
    const clientOptions = getTestOptions()
    const client = SphereClient.create(clientOptions)

    t.deepEqual(client.listServices(), registeredServices,
      'list all registered services')

    registeredServices.forEach((serviceName) => {
      const service = client.getService(serviceName)
      t.ok(service)
    })

    t.end()
  })

  t.test('should register a new service', (t) => {
    const actionsLog = []
    const debugMiddleware = () => next => (action) => {
      // Ignore default registered services
      if (
        action.type === SERVICE_INIT &&
        !registeredServices.includes(action.meta.service)
      )
        actionsLog.push(action)
      return next(action)
    }

    const clientOptions = getTestOptions({
      middlewares: [debugMiddleware],
    })
    const client = SphereClient.create(clientOptions)
    const serviceConfig = {
      type: 'my-new-service',
      endpoint: '/my-service-endpoint',
      features: [
        FEATURE_READ,
        FEATURE_CREATE,
        FEATURE_DELETE,
        FEATURE_QUERY,
        FEATURE_QUERY_ONE,
      ],
    }

    const myNewService =
      client.registerService('my-new-service', serviceConfig)

    t.equal(typeof myNewService, 'object',
      'return the service after registering it')

    t.equal(actionsLog.length, 1, 'dispatch 1 init action')
    t.deepEqual(actionsLog[0],
      {
        type: SERVICE_INIT,
        payload: '/my-service-endpoint',
        meta: { service: 'my-new-service' },
      },
      'dispatch init action'
    )

    t.end()
  })
})
