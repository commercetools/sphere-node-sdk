import 'isomorphic-fetch'
import * as constants from './constants'

function withAuthHeader (auth, headers) {
  if (!auth.accessToken)
    return headers

  const authHeader = `Bearer ${auth.accessToken}`
  if (headers.Authorization && headers.Authorization === authHeader)
    return headers

  return Object.assign({}, headers, {
    'Authorization': `Bearer ${auth.accessToken}`
  })
}

/**
 * Simple HTTP interface. Underlying it uses the `fetch` library
 * and automatically configures it.
 *
 * @param {Object} request options
 * @return {Object}
 */
export default function http (options) {
  fetch.Promise = options.Promise
  const { headers, timeout, agent } = options.request

  return {
    get (url) {
      return fetch(url, { timeout, agent,
        method: constants.get,
        headers: withAuthHeader(options.auth, headers) })
    },
    post (url, body) {
      return fetch(url, { timeout, agent, body,
        method: constants.post,
        headers: withAuthHeader(options.auth, headers) })
    },
    delete (url) {
      return fetch(url, { timeout, agent,
        method: constants.delete,
        headers: withAuthHeader(options.auth, headers) })
    }
  }
}
