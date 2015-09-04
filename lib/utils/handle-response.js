import * as errors from './errors'

export const errorsMap = {
  400: errors.BadRequest,
  401: errors.Unauthorized,
  409: errors.ConcurrentModification,
  500: errors.InternalServerError,
  503: errors.ServiceUnavailable
}


/**
 * Given an object, return a clone with non-function properties defined as
 * non-enumerable, unwritable, and unconfigurable.
 *
 * @param {Object}
 * @return {Object}
 */
export default function handleResponse (httpClient, description) {
  const { url, method } = description
  // TODO: make it configurable to resolve the stream or not

  return httpClient(url, {
    method,
    body: description.body ? (typeof description.body === 'string'
      ? description.body : JSON.stringify(description.body)) : null
  })
  .then(response => {
    if (response.ok)
      return response.json().then(body => {
        const { headers, status } = response
        // Wrap response body
        return { statusCode: status, headers: headers.raw(), body }
      })

    if (response.status === 404) {
      const errorMessage = `Endpoint ${url} not found.`
      throw new errors.NotFound(errorMessage, {
        statusCode: 404,
        message: errorMessage,
        originalRequest: description,
        headers: response.headers.raw()
      })
    }

    return response.text().then(rawBody => {
      let jsonResponse
      try {
        jsonResponse = JSON.parse(rawBody)
      } catch (e) {
        throw new errors.HttpError('Unexpected non-JSON error response.', {
          statusCode: response.status,
          message: rawBody,
          originalRequest: description,
          headers: response.headers.raw()
        })
      }

      const errorMessage =
        jsonResponse.message ||
        jsonResponse.error_description ||
        jsonResponse.error ||
        'Undefined API error message'
      const errorBody = Object.assign({}, jsonResponse, {
        statusCode: jsonResponse.statusCode || response.status,
        originalRequest: description,
        headers: response.headers.raw()
      })

      if (errorsMap[errorBody.statusCode])
        throw new errorsMap[errorBody.statusCode](errorMessage, errorBody)

      throw new errors.HttpError(errorMessage, errorBody)
    })
  })
}
