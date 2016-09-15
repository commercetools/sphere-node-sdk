/* @flow */
import type {
  Middleware,
} from 'redux'
import * as errors from '../utils/errors'
import { TASK_ERROR } from '../constants'

export const errorsMap = new Map([
  [ 400, errors.BadRequest ],
  [ 401, errors.Unauthorized ],
  [ 403, errors.Forbidden ],
  [ 409, errors.ConcurrentModification ],
  [ 500, errors.InternalServerError ],
  [ 503, errors.ServiceUnavailable ],
])

export default function createErrorMiddleware (/* options */): Middleware {
  return (/* middlewareAPI */) => next => action => {
    if (action.type === TASK_ERROR) {
      const {
        meta: { promise: { reject } },
        payload: { statusCode, headers, body, originalRequest },
      } = action

      if (statusCode === 404) {
        const errorMessage = `Endpoint ${originalRequest.url} not found.`
        reject(new errors.NotFound(errorMessage, {
          message: errorMessage,
          statusCode, originalRequest, headers,
        }))
      }

      if (typeof body === 'string')
        reject(new errors.HttpError('Unexpected non-JSON error response.', {
          raw: body,
          statusCode, originalRequest, headers,
        }))

      const errorMessage = gerErrorMessage(body)
      const errorBody = Object.assign({}, body, {
        statusCode, originalRequest, headers,
      })

      const ErrorType = errorsMap.get(errorBody.statusCode) || errors.HttpError
      reject(new ErrorType(errorMessage, errorBody))

      return null
    }

    return next(action)
  }
}


function gerErrorMessage (body: Object): string {
  let message = body.message || body.error_description || body.error
  if (!message)
    if (body.hasOwnProperty('data') && body.hasOwnProperty('errors') &&
      body.data === null)
      message = body.errors.length ? body.errors[0].message : 'GraphQL error'
    else
      message = 'Undefined API error message'

  return message
}
