// if (!global._babelPolyfill)
//   require('babel-polyfill') // eslint-disable-line global-require

import { createStore, compose, applyMiddleware } from 'redux'
import * as version from '../version'
import services from './services'
import * as constants from './constants'
import * as errors from './utils/errors'
import classify from './utils/classify'
import createService from './utils/create-service'
import createGraphQLService from './utils/create-graphql-service'

// Middlewares
import reducers from './reducers'
// import createAuthMiddleware from './middlewares/create-auth'
// import createHttpMiddleware from './middlewares/create-http'
// import createQueueMiddleware from './middlewares/create-queue'
// import createLoggerMiddleware from './middlewares/create-logger'
// import createErrorMiddleware from './middlewares/create-error'

// const userAgent = `${version.name}-${version.version}`

/**
 * Initialize the client `store` with the related middlewares.
 * This should be invoked once per client instance.
 *
 * TODO: allow to inject custom middlewares.
 *
 * @param  {Object} options - the options passed to the client
 * to setup the store and the middlewares.
 * @return {Object} The redux store.
 */
function initStore (options) {
  const {
    projectKey,
    oauth = {
      token: undefined,
      expiresIn: undefined,
    },
    // TODO: document the contract of the middlewares:
    // - the order is important
    // - what are the action types important for the middlewares
    // - when to use `next` and `dispatch`
    middlewares = [],
  } = options

  if (!middlewares.length)
    // TODO: link to middlewares documentation
    throw new Error('No middlewares found.')

  const initialState = {
    request: { projectKey, ...oauth },
  }

  const finalCreateStore = compose(
    applyMiddleware(...middlewares)
  )(createStore)

  return finalCreateStore(reducers, initialState)
}

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
    const { promiseLibrary = Promise } = options
    const store = initStore(options)

    const serviceStore = {}

    Object.keys(services).forEach((key) => {
      const service = createService(services[key])
      serviceStore[key] = service(store, promiseLibrary)
    })

    // The GraphQL service is a bit special, initialize is separately.
    const graphqlService = createGraphQLService()
    serviceStore['graphql'] = graphqlService(store, promiseLibrary)

    // Expose only the following public API.
    return Object.assign(this, {
      getService (name) {
        const service = serviceStore[name]
        if (!service)
          throw new Error(`Wrong service name '${name}', available ` +
            `services are '[${Object.keys(serviceStore).join(', ')}]'`)
        return service
      },

      registerService (name, config) {
        if (name in serviceStore)
          throw new Error(`The service with name '${name}' already exist. ` +
            'Current available services are ' +
            `'[${Object.keys(serviceStore).join(', ')}]'`)
        const service = createService(config)
        serviceStore[name] = service(store, promiseLibrary)
      },
    })
  }
}


// Assign static factory function
SphereClient.create = (...args) => new SphereClient(...args)

// Assign useful static properties to the default export
classify(Object.assign(
  SphereClient,
  { errors, constants, version: version.version }
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
