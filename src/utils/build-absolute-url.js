/**
 * Given `SphereClient` options and an `endpoint`, build an absolute URL
 * for making a request to the HTTP API.
 *
 * @param  {Object} options
 * @param  {String} endpoint - The specific service `endpoint` with all
 * necessary query parameters.
 * @return {String}
 */
export default function buildAbsoluteUrl (options) {
  const {
    endpoint,
    host,
    projectKey,
    protocol,
    urlPrefix,
  } = options

  let url = endpoint

  if (projectKey)
    url = `/${projectKey}${url}`

  if (urlPrefix) {
    const prefix = urlPrefix.charAt(0) === '/'
      ? urlPrefix : `/${urlPrefix}`
    url = prefix + url
  }

  return `${protocol}://${host}${url}`
}
