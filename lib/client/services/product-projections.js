import fetch from 'node-fetch'

// Set promise polyfill for old versions of Node.
// FIXME: make it configurable to provide custom Promise library
fetch.Promise = Promise

// TODO: a service should be a composable object
// e.g.:
//  compose(base, query, create, delete)
// or
//  base.with(query).with(create).with(delete)
export default options => {

  const endpoint = '/product-projections'

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
      const url = this.id ? `${endpoint}/${this.id}` : endpoint
      return fetch(url)
    }
  }

  return productProjections
}
