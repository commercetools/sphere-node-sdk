import 'isomorphic-fetch'
import * as constants from './constants'

/**
 * Internal function to append the `Authorization` header if the
 * `accessToken` is available.
 *
 * @param  {Object} auth - All `auth` options given to `SphereClient`.
 * @param  {Object} headers
 * @return {Object} The updated headers.
 */
function withAuthHeader (auth = {}, headers) {
  if (!auth.accessToken)
    return headers

  const authHeader = `Bearer ${auth.accessToken}`
  if (headers.Authorization && headers.Authorization === authHeader)
    return headers

  return Object.assign({}, {
    'Authorization': `Bearer ${auth.accessToken}`
  }, headers)
}

/**
 * Simple HTTP interface as a wrapper around the `fetch` library.
 * @see  {@link https://fetch.spec.whatwg.org/}
 *
 * @param  {Object} options
 * @return {Function} with same signature as `fetch`
 */
export default function http (options) {
  fetch.Promise = options.Promise
  const { headers, timeout, agent } = options.request

  return (url, opts = {}) => {
    const fetchOptions = Object.assign({}, { timeout, agent }, opts, {
      headers: Object.assign({},
        withAuthHeader(options.auth, headers), opts.headers || {})
    })
    return fetch(url, fetchOptions)
  }
}
