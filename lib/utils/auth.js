import httpFn from './http'
import handleResponse from './handle-response'

/**
 * Given a client credentials, build the URL `endpoint` and `body` for
 * the OAuth HTTP service.
 *
 * @param  {Object} options - The client credentials `projectKey`,
 * `clientId`, `clientSecret`
 * @return {Object}
 */
export function buildRequest (options) {
  const { projectKey, clientId, clientSecret } = options

  const authHost = `https://${clientId}:${clientSecret}@auth.sphere.io`
  const endpoint = `${authHost}/oauth/token`
  const body = 'grant_type=client_credentials' +
    `&scope=manage_project:${projectKey}`

  return { endpoint, body }
}

/**
 * Given `SphereClient` options, retrieve an `access_token`
 * from the OAuth service.
 *
 * @param  {Object} options
 * @return {Promise}
 */
export function getAccessToken (options) {
  const { credentials } = options.auth
  const authRequest = buildRequest(credentials)

  const http = httpFn(Object.assign({}, options, {
    request: Object.assign({}, options.request, {
      headers: Object.assign({}, options.request.headers, {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(authRequest.body)
      })
    })
  }))

  return handleResponse(http, {
    url: authRequest.endpoint,
    method: 'POST',
    body: authRequest.body
  })
}
