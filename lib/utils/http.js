import fetch from 'node-fetch'

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
        headers: withAuthHeader(options.auth, headers) })
    },
    post (url, body) {
      return fetch(url, { body, timeout, agent,
        method: 'POST',
        headers: withAuthHeader(options.auth, headers) })
    },
    delete (url) {
      return fetch(url, { timeout, agent,
        method: 'DELETE',
        headers: withAuthHeader(options.auth, headers) })
    }
  }
}
