import fetch from 'node-fetch'
import * as services from './services'

function defaultOptions (options) {
  const request = options.request || {}

  return {
    request: {
      host: request.host || 'api.sphere.io',
      headers: request.headers || {},
      timeout: request.timeout || 20000
    }
  }
}

function getSphereClient (options = {}) {
  const serviceOptions = defaultOptions(options)

  // Set promise polyfill for old versions of Node.
  // E.g.: `options.promiseLibrary = require('bluebird')`
  fetch.Promise = options.promiseLibrary || Promise

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
