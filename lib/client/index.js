import fetch from 'node-fetch'
import * as services from './services'

function getSphereClient (options) {

  const serviceOptions = {
    request: {
      host: 'https://api.sphere.io'
    }
  }

  // Set promise polyfill for old versions of Node.
  fetch.Promise = options.promiseLib || Promise


  const productProjections = services
    .productProjectionsFn({ request: fetch, options: serviceOptions })

  return { productProjections }
}

export default class SphereClient {

  // const client = SphereClient.create({...})
  static create = getSphereClient

  // const client = new SphereClient({...})
  constructor () {
    return getSphereClient(...arguments)
  }
}
