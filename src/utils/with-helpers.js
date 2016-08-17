/**
 * Utils `with-helpers` module.
 * @module utils/withHelpers
 */

/**
 * Allow to override `auth` credentials. Useful for example for
 * changing `projectKey`.
 *
 * @param  {Object} credentials - The new credentials.
 * @throws If `credentials` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function withCredentials (credentials) {
  if (!credentials || typeof credentials !== 'object')
    throw new Error('Credentials object is missing.')

  Object.assign(this.options.auth.credentials, credentials)
  return this
}

/**
 * Allow to add / merge given header with the current ones.
 *
 * @param  {string} key - The header `key`.
 * @param  {string} value - The header `value`.
 * @throws If `key` or `value` are missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function withHeader (key, value) {
  if (arguments.length !== 2) // eslint-disable-line prefer-rest-params
    throw new Error('Missing required header arguments.')

  Object.assign(this.options.request.headers, { [key]: value })
  return this
}
