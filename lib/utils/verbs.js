/**
 * Utils `verbs` module.
 * @module utils/verbs
 */
import buildQueryString from './build-query-string'
import { setDefaultParams } from './default-params'

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
 * @return {Promise} A `task` promise that will eventually be resolved.
 *
 * @example
 *
 * ```js
 * service = client.productProjections
 * service.where('name(en = "Foo")').sort('createdAt desc').fetch()
 * .then()
 * .catch()
 * ```
 */
export function fetch () {
  const endpointWithId = this.params.id ?
    `${this.baseEndpoint}/${this.params.id}` : this.baseEndpoint
  const queryParams =
    this.params.customQuery || buildQueryString(this.params)
  const endpoint = endpointWithId + (queryParams ? `?${queryParams}` : '')
  const url = absoluteUrl(this.options, endpoint)

  setDefaultParams.call(this)
  return this.queue.addTask({ method: 'GET', url })
}

/**
 * Create a resource defined by the `service`.
 *
 * @param  {Object} body - The payload described by the related API resource.
 * @throws If `body` is missing.
 * @return {Promise} A `task` promise that will eventually be resolved.
 *
 * @example
 *
 * ```js
 * service = client.products
 * service.create({
 *   name: { en: 'Foo' },
 *   slug: { en: 'foo' },
 *   productType: { id: '123', typeId: 'product-type'}
 * })
 * .then()
 * .catch()
 * ```
 */
export function create (body) {
  if (!body)
    throw new Error('Body payload is required for creating a resource ' +
      `(endpoint: ${this.baseEndpoint})`)

  // TODO: allow to pass `expand` query params
  const url = absoluteUrl(this.options, this.baseEndpoint)

  setDefaultParams.call(this)
  return this.queue.addTask({ method: 'POST', url, body })
}

/**
 * Update a resource defined by the `service`.
 *
 * @param  {Object} body - The payload described by the related API resource.
 * @throws If `body` and `id` are missing.
 * @return {Promise} A `task` promise that will eventually be resolved.
 *
 * @example
 *
 * ```js
 * service = client.products.byId('123')
 * service.update({
 *   version: 1,
 *   actions: [{ action: 'setName', name: { en: 'Foo' }}]
 * })
 * .then()
 * .catch()
 * ```
 */
export function update (body) {
  if (!body)
    throw new Error('Body payload is required for updating a resource.')
  if (!this.params.id)
    throw new Error('Missing required `id` param for updating a resource. ' +
      'You can set it by chaining `.byId(<id>).update({})`')

  const endpoint = `${this.baseEndpoint}/${this.params.id}`
  // TODO: allow to pass `expand` query params
  const url = absoluteUrl(this.options, endpoint)

  setDefaultParams.call(this)
  return this.queue.addTask({ method: 'POST', url, body })
}

/**
 * Delete a resource defined by the `service`.
 *
 * @param  {number} version - The current version of the resource.
 * @throws If `version` and `id` are missing.
 * @return {Promise} A `task` promise that will eventually be resolved.
 *
 * @example
 *
 * ```js
 * service = client.products.byId('123')
 * service.delete(1)
 * .then()
 * .catch()
 * ```
 */
function _delete (version) {
  if (!version)
    throw new Error('Version number is required for deleting a resource.')
  if (!this.params.id)
    throw new Error('Missing required `id` param for deleting a resource. ' +
      'You can set it by chaining `.byId(<id>).delete(<version>)`')

  const endpoint = `${this.baseEndpoint}/${this.params.id}?version=${version}`
  const url = absoluteUrl(this.options, endpoint)

  setDefaultParams.call(this)
  return this.queue.addTask({ method: 'DELETE', url })
}
export { _delete as delete }
