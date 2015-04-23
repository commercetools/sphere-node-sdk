import * as base from './commons/base'
import * as query from './commons/query'
import * as utils from '../../utils'

const BASE_ENDPOINT = '/product-projections'

export default (deps) => {
  return utils.compose(deps, base, query, {
    baseEndpoint: BASE_ENDPOINT,
    params: {}
  })
}
