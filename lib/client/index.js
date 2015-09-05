import * as services from './services'
import taskQueueFn from '../utils/task-queue'

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
    }
  }
}

/**
 * Create a new instance of `SphereClient`.
 *
 * @param  {Object} options
 * @return {Object} An object with all available services as properties.
 */
function getSphereClient (options = {}) {
  const serviceOptions = defaultOptions(options)

  // Init services
  return Object.keys(services).reduce((memo, key) => {
    const name = key.replace('Fn', '')
    memo[name] = services[key]({
      queue: taskQueueFn(serviceOptions),
      options: serviceOptions
    })
    return memo
  }, {})
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
class SphereClient {
  constructor () {
    return getSphereClient(...arguments)
  }
}
SphereClient.create = getSphereClient

export default SphereClient
