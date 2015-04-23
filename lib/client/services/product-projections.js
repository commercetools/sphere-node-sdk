import * as base from './commons/base'
import * as query from './commons/query'
import * as utils from '../../utils'

export default (deps) => {
  return utils.compose(deps, base, query, {
    baseEndpoint: '/product-projections',
    params: {}
  })
}
