if (!global._babelPolyfill)
  require('babel-polyfill') // eslint-disable-line global-require

import * as version from '../version'
import services from './services'
import * as errors from './utils/errors'
import * as features from './utils/features'
import http from './utils/http'
import classify from './utils/classify'
import createService from './utils/create-service'
import createGraphQLService from './utils/create-graphql-service'
import taskQueueFn from './utils/task-queue'

const userAgent = `${version.name}-${version.version}`

/**
 * Set default options for initializing `SphereClient`.
 *
 * @param  {Object} options
 * @return {Object}
 */
function defaultOptions (options = {}) {
  const auth = options.auth || {}
  const request = options.request || {}

  return {
    // Set promise polyfill for old versions of Node.
    // E.g.: `options.Promise = require('bluebird')`
    Promise: options.Promise || Promise,
    auth: {
      accessToken: auth.accessToken,
      credentials: auth.credentials || {},
      shouldRetrieveToken: auth.shouldRetrieveToken || (cb => { cb(true) }),
      host: auth.host || 'auth.sphere.io',
    },
    request: {
      agent: request.agent,
      headers: request.headers || { 'User-Agent': userAgent },
      host: request.host || 'api.sphere.io',
      maxParallel: request.maxParallel || 20,
      protocol: request.protocol || 'https',
      timeout: request.timeout || 20000,
      urlPrefix: request.urlPrefix,
    },
    // TODO: find a better solution?
    httpMock: options.httpMock,
  }
}

function initService (name, service, options = {}) {
  const serviceOptions = defaultOptions(options)

  this[name] = service({
    queue: taskQueueFn(serviceOptions),
    options: serviceOptions,
  })
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
 * TODO: list available options
 */
export default class SphereClient {
  constructor (...args) {
    Object.keys(services).forEach(key => {
      const service = createService(services[key])
      initService.call(this, key, service, ...args)
    })
    const graphqlService = createGraphQLService()
    initService.call(this, 'graphql', graphqlService, ...args)
  }

  registerService (name, config, options) {
    // TODO: validate service name
    const service = createService(config)
    initService.call(this, name, service, options)
  }

  replaceHttpClient (httpClient) {
    Object.keys(this).forEach(key => {
      this[key].options.httpMock = httpClient
    })
  }
}

// Assign static factory function
SphereClient.create = (...args) => new SphereClient(...args)

// Assign useful static properties to the default export
classify(Object.assign(SphereClient, { errors, features, http }), true)
