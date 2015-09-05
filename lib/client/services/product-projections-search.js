import { getDefaultSearchParams } from '../../utils/default-params'
import classify from '../../utils/classify'
import * as headers from '../utils/headers'
import * as verbs from '../../utils/verbs'
import * as queryPage from '../../utils/query-page'
import * as queryProjection from '../../utils/query-projection'
import * as querySearch from '../../utils/query-search'

const type = 'product-projections-search'
const baseEndpoint = '/product-projections/search'

/**
 * A `productProjectionsSearch` service.
 *
 * TODO: list all available methods
 *
 * @param  {Object} deps - A config object injected to the service.
 * @return {Object} An composed object decorated with the necessary properties
 * for the given service
 */
export default deps => classify(
  Object.assign({}, deps, headers, queryPage, queryProjection, querySearch,
    { fetch: verbs.fetch },
    {
      baseEndpoint, type,
      params: getDefaultSearchParams()
    }
  ))
