import { getDefaultQueryParams } from '../../utils/default-params'
import classify from '../../utils/classify'
import * as headers from '../utils/headers'
import * as verbs from '../../utils/verbs'
import * as query from '../../utils/query'
import * as queryId from '../../utils/query-id'
import * as queryPage from '../../utils/query-page'

const type = 'product-types'
const baseEndpoint = `/${type}`

/**
 * A `productTypes` service.
 *
 * TODO: list all available methods
 *
 * @param  {Object} deps - A config object injected to the service.
 * @return {Object} An composed object decorated with the necessary properties
 * for the given service
 */
export default deps => classify(
  Object.assign({}, deps, headers, query, queryId, queryPage, verbs, {
    baseEndpoint, type,
    params: getDefaultQueryParams()
  }))
