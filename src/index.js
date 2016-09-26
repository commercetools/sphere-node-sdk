import * as version from '../version'
import services from './services'
import * as constants from './constants'
import * as errors from './utils/errors'
import classify from './utils/classify'
import createService from './utils/create-service'
import createGraphQLService from './utils/create-graphql-service'
import initStore from './utils/init-store'

// const userAgent = `${version.name}-${version.version}`

/**
 * A `SphereClient` class that exposes `services` specific for each
 * endpoint of the HTTP API.
 * It can be configured by passing some options.
 *
 * @example
 *
 * ```js
 * const client = SphereClient.create({...})
 * const client = new SphereClient({...})
 * ```
 *
 * Available options are:
 * ```js
 * const options = {
 *   // Pass a custom promise library (e.g. 'bluebird).
 *   // Default is the native `Promise`.
 *   promiseLibrary: Object || Promise,
 *
 *   // The given project key (can be also injected from the service).
 *   projectKey: String,
 *
 *   // Can be used to initialize the client with an existing token.
 *   oauth: {
 *     token: String,
 *     expiresIn: Number,
 *   },
 *
 *   middlewares: [
 *     createAuthMiddleware({...}),
 *     createHttpMiddleware({...}),
 *     createErrorMiddleware({...}),
 *   ],
 * }
 * ````
 */
export default class SphereClient {
  constructor (options) {
    // TODO: make it a global?
    const { promiseLibrary = Promise } = options

    // Initialize redux store.
    const store = initStore(options)

    // Initialize object map that holds all the services.
    const serviceStore = {}

    // Initialize each service and add it to the map.
    Object.keys(services).forEach((key) => {
      serviceStore[key] = createService(services[key], store, promiseLibrary)
    })

    // The GraphQL service is a bit special, initialize is separately.
    serviceStore['graphql'] = createGraphQLService(store, promiseLibrary)

    // Expose only the following public API.
    return Object.assign(this, {

      // Get a service by it's name / key.
      getService (name) {
        if (!(name in serviceStore))
          throw new Error(
            `Wrong service name '${name}', available ` +
            `services are '[${Object.keys(serviceStore).join(', ')}]'`
          )
        return serviceStore[name]
      },

      // Register a new service based on the given configuration.
      // Throws if a service with the same name already exists.
      registerService (name, config) {
        if (name in serviceStore)
          throw new Error(
            `The service with name '${name}' already exist. ` +
            'Current available services are ' +
            `'[${Object.keys(serviceStore).join(', ')}]'`
          )
        serviceStore[name] = createService(config, store, promiseLibrary)
        return serviceStore[name]
      },

      listServices () {
        return Object.keys(serviceStore)
      },

      // TODO: expose other useful methods
    })
  }
}

// Assign static factory function
SphereClient.create = (...args) => new SphereClient(...args)

// Assign useful static properties to the default export
classify(Object.assign(
  SphereClient,
  {
    errors,
    constants,
    version: version.version,
  }
), true)

/* eslint-disable max-len */
// Export sync utils
export { default as createSyncCategories } from './sync/categories'
export { default as createSyncInventories } from './sync/inventories'
export { default as createSyncProducts } from './sync/products'

// Export middleware utils
export { default as createAuthMiddleware } from './middlewares/create-auth-middleware'
export { default as createHttpMiddleware } from './middlewares/create-http-middleware'
export { default as createQueueMiddleware } from './middlewares/create-queue-middleware'
export { default as createLoggerMiddleware } from './middlewares/create-logger-middleware'
export { default as createErrorMiddleware } from './middlewares/create-error-middleware'

// TODO: expose a default middlewares preset
