import * as services from './services'

// const client = SphereClient({...})
export default options => {

  class SphereClient {

    get productProjections () {
      const { productProjectionsFn } = services
      return productProjectionsFn({}) // TODO: inject what service needs
    }
  }

  return new SphereClient()
}
