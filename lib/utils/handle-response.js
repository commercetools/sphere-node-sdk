import * as errors from './errors'

/**
 * Given an object, return a clone with non-function properties defined as
 * non-enumerable, unwritable, and unconfigurable.
 *
 * @param {Object}
 * @return {Object}
 */
export function handleResponse (promise) {
  // TODO: make it configurable to resolve the stream or not
  return promise
  .then(response => {
    if (response.ok) return Promise.resolve(response)
    else return Promise.reject(response)
  })
  .then(response => response.json().then(body => {
    // Wrap response body
    return { statusCode: response.status, body }
  }))
  .catch(errorOrResponse => {
    if (errorOrResponse instanceof Error)
      throw errorOrResponse

    const respContentType = errorOrResponse.headers.get('content-type')
    if (respContentType === 'text/html')
      return errorOrResponse.text().then(handleResponseError)

    return errorOrResponse.json().then(handleResponseError)
  })
}

export function handleResponseError (response) {
  // TODO: handle non json error response

  const errorMessage = response.message || response.error_description ||
    response.error || 'Undefined SPHERE.IO error message'
  // TODO: wrap error body with original payload
  throw new errors.SphereError(errorMessage, response)
}
