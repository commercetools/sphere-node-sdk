import services from './services'
import * as errors from './utils/errors'
import http from './utils/http'
import classify from './utils/classify'
import createService from './utils/create-service'
import taskQueueFn from './utils/task-queue'

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
      shouldRetrieveToken: auth.shouldRetrieveToken || (cb => { cb(true) })
    },
    request: {
      agent: request.agent,
      // FIXME: define a `version.js` file
      headers: request.headers || { 'User-Agent': 'sphere-node-sdk-2.0' },
      host: request.host || 'api.sphere.io',
      maxParallel: request.maxParallel || 20,
      protocol: request.protocol || 'https',
      timeout: request.timeout || 20000,
      urlPrefix: request.urlPrefix
    },
    // TODO: find a better solution?
    httpMock: null
  }
}

function initService (name, service, options = {}) {
  const serviceOptions = defaultOptions(options)

  this[name] = service({
    queue: taskQueueFn(serviceOptions),
    options: serviceOptions
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
  constructor () {
    Object.keys(services).forEach(key => {
      const service = createService(services[key])
      initService.call(this, key, service, ...arguments)
    })
  }

  registerService (name, config, options) {
    const service = createService(config)
    initService.call(this, name, service, options)
  }
}
SphereClient.create = (...args) => {
  return new SphereClient(...args)
}

// Assign useful static properties to the default export
classify(Object.assign(SphereClient, { errors, http }), true)
