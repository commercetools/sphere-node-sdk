/* @flow */
import type {
  Middleware,
} from 'redux'
import {
  BadRequest,
  Unauthorized,
  Forbidden,
  ConcurrentModification,
  InternalServerError,
  ServiceUnavailable,
  NotFound,
  HttpError,
} from '../utils/errors'
import { TASK_ERROR } from '../constants'

export const errorsMap = new Map([
  [ 400, BadRequest ],
  [ 401, Unauthorized ],
  [ 403, Forbidden ],
  [ 409, ConcurrentModification ],
  [ 500, InternalServerError ],
  [ 503, ServiceUnavailable ],
])

export default function createErrorMiddleware (/* options */): Middleware {
  return function errorMiddleware (/* middlewareAPI */) {
    return next => action => {
      if (action.type === TASK_ERROR) {
        const {
          meta: { promise: { reject } },
          payload: { statusCode, headers, body, originalRequest },
        } = action

        if (statusCode === 404) {
          const errorMessage = `Endpoint ${originalRequest.url} not found.`
          reject(new NotFound(errorMessage, {
            message: errorMessage,
            statusCode, originalRequest, headers,
          }))
        }

        if (typeof body === 'string')
          reject(new HttpError('Unexpected non-JSON error response.', {
            raw: body,
            statusCode, originalRequest, headers,
          }))

        const errorMessage = gerErrorMessage(body)
        const errorBody = Object.assign({}, body, {
          statusCode, originalRequest, headers,
        })

        const ErrorType = errorsMap.get(errorBody.statusCode) || HttpError
        reject(new ErrorType(errorMessage, errorBody))

        return null
      }

      return next(action)
    }
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
