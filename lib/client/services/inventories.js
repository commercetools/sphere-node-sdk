// import * as commons from './commons'

// const { base, query } = commons


function base (request, options) {

  return {
    // should be overriden by each service
    baseEndpoint: '/',

    params: {},

    fetch () {
      const endpoint = this.params.id ?
        `${this.baseEndpoint}/${this.params.id}` : this.baseEndpoint
      return request(options.request.host + endpoint)
    }
  }
}

function query (request, options) {

  return {
    byId (id) {
      const copy = Object.assign({}, this)
      copy.params.id = id
      return Object.freeze(copy)
    },

    where (predicate) {
      const copy = Object.assign({}, this)
      copy.params.where = predicate
      return Object.freeze(copy)
    }
  }
}

export default (request, options) => {

  return Object.freeze(Object.assign({},
    base(request, options),
    query(request, options),
    {
      baseEndpoint: '/inventory'
    }))
}
