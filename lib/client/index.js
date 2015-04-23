import fetch from 'node-fetch'
import * as services from './services'

// const client = SphereClient({...})
export default options => {

  const serviceOptions = {
    request: {
      host: 'https://api.sphere.io'
    }
  }

  // Set promise polyfill for old versions of Node.
  fetch.Promise = options.promiseLib || Promise

  const initService = (name) => {
    const service = Object.assign({}, services[name])
    service.request = fetch
    service.options = serviceOptions
    return Object.freeze(service)
  }

  const productProjections = initService('productProjections')
  const inventories = services.inventoriesFn(fetch, serviceOptions)

  return { productProjections, inventories }
}
