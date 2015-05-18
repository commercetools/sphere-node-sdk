import * as base from './commons/base'
import * as query from './commons/query'
import * as utils from '../../utils'

const BASE_ENDPOINT = '/product-projections'

/**
 * A `productProjections` service.
 *
 * TODO: list all available methods
 */
export default deps => utils.classify(
  Object.assign({}, deps, base, query, {
    baseEndpoint: BASE_ENDPOINT,
    params: {}
  }))
