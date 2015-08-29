import * as base from './commons/base'
import * as query from './commons/query'
import * as utils from '../../utils'

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
export default deps => utils.classify(
  Object.assign({}, deps, base, query, {
    baseEndpoint: BASE_ENDPOINT,
    // Instance container that will gather all request parameters.
    // Will be reset when a request promise is created
    // (e.g.: `fetch`, `create`)
    params: {}
  }))
