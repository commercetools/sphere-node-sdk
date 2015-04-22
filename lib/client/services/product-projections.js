// TODO: a service should be a composable object
// e.g.:
//  compose(base, query, create, delete)
// or
//  base.with(query).with(create).with(delete)
export default (request, options) => {

  const BASE_ENDPOINT = '/product-projections'

  // TODO: just for now, ideally it should be a composable object
  const productProjections = {
    byId (id) {
      this.id = id
      return this
    },

    where (predicate) {
      this.where = predicate
      return this
    },

    fetch () {
      const endpoint = this.id ? `${BASE_ENDPOINT}/${this.id}` : BASE_ENDPOINT
      return request(options.request.host + endpoint)
    }
  }

  return productProjections
}
