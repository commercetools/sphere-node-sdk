// TODO: just a simple implementation for now, to get an auth token
export function buildRequest (options) {
  const { projectKey, clientId, clientSecret } = options

  const authHost = `https://${clientId}:${clientSecret}@auth.sphere.io`
  const endpoint = `${authHost}/oauth/token`
  const body = 'grant_type=client_credentials' +
    `&scope=manage_project:${projectKey}`

  return { endpoint, body }
}
