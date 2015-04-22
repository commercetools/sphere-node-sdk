const BASE_ENDPOINT = '/product-projections'

// TODO: a service should be a composable object
// e.g.:
//  compose(base, query, create, delete)
// or
//  base.with(query).with(create).with(delete)
export default Object.freeze({
  byId (id) {
    const copy = Object.assign({}, this)
    copy.id = id
    return Object.freeze(copy)
  },

  where (predicate) {
    const copy = Object.assign({}, this)
    copy.where = predicate
    return Object.freeze(copy)
  },

  fetch () {
    const endpoint = this.id ? `${BASE_ENDPOINT}/${this.id}` : BASE_ENDPOINT
    return this.request(this.options.request.host + endpoint)
  }
})
