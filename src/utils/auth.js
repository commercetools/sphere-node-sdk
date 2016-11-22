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
  const {
    host,
    credentials: { projectKey, clientId, clientSecret },
  } = options

  const authHost = `https://${host}`
  const endpoint = `${authHost}/oauth/token`
  const body = 'grant_type=client_credentials' +
    `&scope=manage_project:${projectKey}`

  // Notes on the encoding:
  // Since result is smaller than 76 chars the "MIME" restrictions for base64
  //    can be ignored.
  // Since the sdk is compatibly only IE10+ , using btoa() is OK
  // Browser vs. Node polyfill for String to base64 encoded String:
  const base64 = (typeof btoa === 'function') ?
    btoa :
    str => new Buffer(str.toString(), 'binary').toString('base64')
  const basicAuthRaw = `${clientId}:${clientSecret}`
  const authorizationHeader = `Basic ${base64(basicAuthRaw)}`

  return { endpoint, body, authorizationHeader }
}

/**
 * Given `SphereClient` options, retrieve an `access_token`
 * from the OAuth service.
 *
 * @param  {Object} options
 * @return {Promise}
 */
export function getAccessToken (options) {
  const authRequest = buildRequest(options.auth)

  const http = httpFn(Object.assign({}, options, {
    request: Object.assign({}, options.request, {
      headers: Object.assign({}, options.request.headers, {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(authRequest.body),
        Authorization: authRequest.authorizationHeader,
      }),
    }),
  }))

  return handleResponse(http, {
    url: authRequest.endpoint,
    method: 'POST',
    body: authRequest.body,
  })
}
