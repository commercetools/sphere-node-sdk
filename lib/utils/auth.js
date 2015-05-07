import httpFn from './http'

export function buildRequest (options) {
  const { projectKey, clientId, clientSecret } = options

  const authHost = `https://${clientId}:${clientSecret}@auth.sphere.io`
  const endpoint = `${authHost}/oauth/token`
  const body = 'grant_type=client_credentials' +
    `&scope=manage_project:${projectKey}`

  return { endpoint, body }
}

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
    http.post(authRequest.endpoint, authRequest.body)
      .then(res => {
        // TODO: better error handling!
        if (res.ok)
          res.json().then(result => resolve(result))
        else
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
