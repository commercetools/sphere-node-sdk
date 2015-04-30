import * as services from './services'
import http from '../utils/http'

function defaultOptions (options) {
  const request = options.request || {}

  return {
    // Set promise polyfill for old versions of Node.
    // E.g.: `options.Promise = require('bluebird')`
    Promise: options.Promise || Promise,
    request: {
      agent: request.agent,
      headers: request.headers || {},
      host: request.host || 'api.sphere.io',
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
      http: http(serviceOptions),
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
