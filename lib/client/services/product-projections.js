import * as base from './commons/base'
import * as query from './commons/query'
import classify from '../../utils/classify'

const BASE_ENDPOINT = '/product-projections'

export default deps => classify(
  Object.assign({}, deps, base, query, {
    baseEndpoint: BASE_ENDPOINT,
    params: {}
  }))
