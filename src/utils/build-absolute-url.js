/**
 * Given `SphereClient` options and an `endpoint`, build an absolute URL
 * for making a request to the HTTP API.
 *
 * @param  {Object} options
 * @param  {String} endpoint - The specific service `endpoint` with all
 * necessary query parameters.
 * @return {String}
 */
export default function buildAbsoluteUrl (options, endpoint) {
  const { auth, request } = options
  let url = endpoint

  if (auth.credentials.projectKey)
    url = `/${auth.credentials.projectKey}${url}`

  if (request.urlPrefix) {
    const prefix = request.urlPrefix.charAt(0) === '/' ?
      request.urlPrefix : `/${request.urlPrefix}`
    url = prefix + url
  }

  return `${request.protocol}://${request.host}${url}`
}
