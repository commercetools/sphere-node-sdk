import * as verbs from './commons/verbs'
import * as query from './commons/query'
import * as queryId from './commons/query-id'
import { getDefaultQueryParams } from './commons/default-params'
import classify from '../../utils/classify'

const BASE_ENDPOINT = '/product-projections'

/**
 * A `productProjections` service.
 *
 * TODO: list all available methods
 *
 * @param  {Object} deps - A config object injected to the service.
 * @return {Object} An composed object decorated with the necessary properties
 * for the given service
 */
export default deps => classify(
  Object.assign({}, deps, queryId, query, verbs, {
    baseEndpoint: BASE_ENDPOINT,
    params: getDefaultQueryParams()
  }))
