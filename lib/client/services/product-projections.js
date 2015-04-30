import * as base from './commons/base'
import * as query from './commons/query'
import compose from '../../utils/compose'

const BASE_ENDPOINT = '/product-projections'

export default (deps) => {
  return compose(deps, base, query, {
    baseEndpoint: BASE_ENDPOINT,
    params: {}
  })
}
