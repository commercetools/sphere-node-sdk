import { getDefaultQueryParams } from '../../utils/default-params'
import classify from '../../utils/classify'
import * as verbs from '../../utils/verbs'
import * as query from '../../utils/query'
import * as queryId from '../../utils/query-id'

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
  Object.assign({}, deps, queryId, query, { fetch: verbs.fetch }, {
    baseEndpoint: BASE_ENDPOINT,
    params: getDefaultQueryParams()
  }))
