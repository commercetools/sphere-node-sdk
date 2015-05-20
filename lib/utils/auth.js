import httpFn from './http'

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
        'Content-Length': `${authRequest.body.length}`
      })
    })
  }))

  return new options.Promise((resolve, reject) => {
    http(authRequest.endpoint, { method: 'POST', body: authRequest.body })
      .then(res => {
        // TODO: better error handling!
        if (res.ok)
          res.json().then(result => resolve(result))
        else
          // the request failed, we parse it and `reject` the Promise
          if (res.headers.has('content-type') &&
            new RegExp(/application\/json/)
              .test(res.headers.get('content-type')))
            res.json().then(reject)
          else
            res.text().then(reject)
      })
      .catch(reject)
  })
}
