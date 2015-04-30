import fetch from 'node-fetch'

/**
 * Simple HTTP interface. Underlying it uses the `fetch` library
 * and automatically configure it.
 *
 * @param {Object} request options
 * @return {Object}
 */
export default function http (options) {
  fetch.Promise = options.Promise
  const { headers, timeout, agent } = options.request

  return {
    get (url) {
      return fetch(url, { headers, timeout, agent })
    },
    post (url, body) {
      return fetch(url, { method: 'POST', body, headers, timeout, agent })
    },
    delete (url) {
      return fetch(url, { method: 'DELETE', headers, timeout, agent })
    }
  }
}
