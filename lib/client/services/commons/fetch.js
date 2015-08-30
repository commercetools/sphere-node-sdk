/**
 * Commons `fetch` module.
 * @module commons/fetch
 */
import * as utils from '../../../utils'

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
  const endpoint = this.params.id ?
    `${this.baseEndpoint}/${this.params.id}` : this.baseEndpoint

  // TODO: build query string params
  const queryParams = ''
  const url = absoluteUrl(this.options, endpoint + queryParams)

  // TODO: reset default parameters

  return this.queue.addTask({ method: utils.constants.get, url })
}
