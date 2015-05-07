import * as services from './services'
import taskQueueFn from '../utils/task-queue'

function defaultOptions (options) {
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
      headers: request.headers || {},
      host: request.host || 'api.sphere.io',
      maxParallel: request.maxParallel || 20,
      protocol: request.protocol || 'https',
      timeout: request.timeout || 20000,
      urlPrefix: request.urlPrefix
    }
  }
}

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

export default class SphereClient {

  // const client = SphereClient.create({...})
  static create = getSphereClient

  // const client = new SphereClient({...})
  constructor () {
    return getSphereClient(...arguments)
  }
}
