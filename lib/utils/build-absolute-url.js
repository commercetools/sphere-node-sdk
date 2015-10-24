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

  if (auth.credentials.projectKey)
    endpoint = '/' + auth.credentials.projectKey + endpoint

  if (request.urlPrefix) {
    const prefix = request.urlPrefix.charAt(0) === '/' ?
      request.urlPrefix : `/${request.urlPrefix}`
    endpoint = prefix + endpoint
  }

  return `${request.protocol}://${request.host}${endpoint}`
}
