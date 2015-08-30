import * as fetch from './commons/fetch'
import * as query from './commons/query'
import * as queryId from './commons/query-id'
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
  Object.assign({}, deps, queryId, query, fetch, {
    baseEndpoint: BASE_ENDPOINT,
    // Instance container that will gather all request parameters.
    // Will be reset when a request promise is created
    // (e.g.: `fetch`, `create`)
    //
    // TODO: make it a getter / setter so that it's easier
    // to set the defaults
    params: {
      id: null,
      query: {
        expand: [],
        operator: 'and',
        page: 1,
        perPage: 25,
        sort: [],
        where: []
      }
    }
  }))
