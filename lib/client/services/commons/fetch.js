/**
 * Commons `fetch` module.
 * @module commons/fetch
 */
import buildQueryString from '../../../utils/build-query-string'
import * as constants from '../../../utils/constants'
import { setDefaultQueryParams } from './default-params'

/**
 * Given `SphereClient` options and an `endpoint`, build an absolute URL
 * for making a request to the HTTP API.
 *
 * @param  {Object} options
 * @param  {String} endpoint - The specific service `endpoint` with all
 * necessary query parameters.
 * @return {String}
 */
function absoluteUrl (options, endpoint) {
  const { auth, request } = options

  if (auth.credentials.projectKey)
    endpoint = '/' + auth.credentials.projectKey + endpoint

  if (request.urlPrefix) {
    const prefix = request.urlPrefix.charAt(0) === '/' ?
      request.urlPrefix : `/${request.urlPrefix}`
    endpoint = prefix + endpoint
  }

  return `${request.protocol}://${request.host}${endpoint}`
}

/**
 * Fetch a resource defined by the `service` with all related query parameters.
 *
 * @example
 *
 * ```js
 * service = client.products
 * service.where('name(en = "Foo")').sort('createdAt desc').fetch()
 * .then()
 * .catch()
 * ```
 *
 * @return {Promise} A `task` promise that will eventually be resolved.
 */
export function fetch () {
  const endpointWithId = this.params.id ?
    `${this.baseEndpoint}/${this.params.id}` : this.baseEndpoint
  const queryParams = buildQueryString(this.params.query)
  const endpoint = endpointWithId + (queryParams ? `?${queryParams}` : '')
  const url = absoluteUrl(this.options, endpoint)

  setDefaultQueryParams(this.params)

  return this.queue.addTask({ method: constants.get, url })
}
