import http from 'http'
import * as errors from './errors'

const errorsMap = {
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
        // Wrap response body
        return { statusCode: response.status, body }
      })

    else {
      if (response.status === 404) {
        const errorMessage = `Endpoint ${url} not found.`
        throw new errors.NotFound(errorMessage, {
          statusCode: 404, message: errorMessage, originalRequest: description
        })
      }

      const respContentType = response.headers.get('content-type')
      if (respContentType === 'text/html')
        return response.text().then(res => {
          throw new errors.HttpError(
            'Unexpected non-JSON error response.', res)
        })

      return response.json().then(res => {
        const errorMessage =
          res.message ||
          res.error_description ||
          res.error ||
          'Undefined API error message'
        const errorBody = Object.assign({}, res, {
          statusCode: res.statusCode || response.status,
          originalRequest: description
        })

        if (errorsMap[errorBody.statusCode])
          throw new errorsMap[errorBody.statusCode](errorMessage, errorBody)

        throw new errors.HttpError(`Unknown error with code ` +
          `${http.STATUS_CODES[errorBody.statusCode]}`, errorBody)
      })
    }
  })
}
