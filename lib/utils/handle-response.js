import * as errors from './errors'

export const errorsMap = {
  400: errors.BadRequest,
  401: errors.Unauthorized,
  403: errors.Forbidden,
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

  return httpClient(url, Object.assign({ method },
    description.body ? { body: typeof description.body === 'string' ?
      description.body : JSON.stringify(description.body) } : null
  ))
  .then(response => {
    const { headers, status } = response
    if (response.ok)
      return response.json().then(body => {
        // Wrap response body
        return { statusCode: status, headers: parseHeaders(headers), body }
      })

    if (status === 404) {
      const errorMessage = `Endpoint ${url} not found.`
      throw new errors.NotFound(errorMessage, {
        statusCode: 404,
        message: errorMessage,
        originalRequest: description,
        headers: parseHeaders(headers)
      })
    }

    return response.text().then(rawBody => {
      let jsonResponse
      try {
        jsonResponse = JSON.parse(rawBody)
      } catch (e) {
        throw new errors.HttpError('Unexpected non-JSON error response.', {
          statusCode: status,
          raw: rawBody,
          originalRequest: description,
          headers: parseHeaders(headers)
        })
      }

      const errorMessage =
        jsonResponse.message ||
        jsonResponse.error_description ||
        jsonResponse.error ||
        'Undefined API error message'
      const errorBody = Object.assign({}, jsonResponse, {
        statusCode: jsonResponse.statusCode || status,
        originalRequest: description,
        headers: parseHeaders(headers)
      })

      if (errorsMap[errorBody.statusCode])
        throw new errorsMap[errorBody.statusCode](errorMessage, errorBody)

      throw new errors.HttpError(errorMessage, errorBody)
    })
  })
}

function parseHeaders (headers) {
  if (headers.raw)
    // node-fetch
    return headers.raw()
  else {
    // Tmp fix for Firefox until it supports iterables
    if (!headers.forEach) return {}

    // whatwg-fetch
    const map = {}
    headers.forEach((value, name) => {
      map[name] = value
    })
    return map
  }
}
