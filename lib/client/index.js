import fetch from 'node-fetch'
import * as services from './services'

// Set promise polyfill for old versions of Node.
// FIXME: make it configurable to provide custom Promise library
fetch.Promise = Promise

// const client = SphereClient({...})
export default options => {

  const serviceOptions = {
    request: {
      host: 'https://api.sphere.io'
    }
  }

  class SphereClient {

    get productProjections () {
      const { productProjectionsFn } = services
      return productProjectionsFn(fetch, serviceOptions)
    }
  }

  return new SphereClient()
}
