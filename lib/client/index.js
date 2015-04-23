import fetch from 'node-fetch'
import * as services from './services'

function defaultOptions (options) {
  const request = options.request || {}

  return {
    request: {
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

  // Set promise polyfill for old versions of Node.
  // E.g.: `options.Promise = require('bluebird')`
  fetch.Promise = options.Promise || Promise

  // Init services
  return Object.keys(services).reduce((memo, key) => {
    const name = key.replace('Fn', '')
    memo[name] = services[key]({ request: fetch, options: serviceOptions })
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
