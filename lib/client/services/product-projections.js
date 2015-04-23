import * as base from './commons/base'
import * as query from './commons/query'

export default (deps) => {
  return Object.assign({}, deps, base, query, {
    baseEndpoint: '/product-projections',
    params: {}
  })
}
