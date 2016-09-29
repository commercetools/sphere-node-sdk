/* global fetch */
/* @flow */
import type {
  Middleware,
  MiddlewareAPI,
} from 'redux'
import 'isomorphic-fetch'
import processResponse from '../utils/process-response'
import { TASK, TASK_ERROR, REQUEST_TOKEN } from '../constants'

// TODO: define authMiddleware type with options

export default function createAuthMiddleware (options: Object): Middleware {
  const {
    clientId,
    clientSecret,
    host = 'auth.sphere.io',
    protocol = 'https',
    agent,
    headers,
    timeout = 20000,
    httpMock,
  } = options || {}

  const http = httpMock || fetch
  const httpOptions = {
    clientId, clientSecret, host, protocol, headers, agent, timeout,
  }

  return function authMiddleware ({ dispatch, getState }: MiddlewareAPI) {
    const pendingTasks = []
    let isGettingToken = false

    return next => (action) => {
      const { request: { token } } = getState()
      // TODO: validate expiration date

      // The token exists, pass the action to the next middleware
      if (token) return next(action)

      // At this point, a new token has been created. We make sure first
      // that the token is put into state, then we dispatch all actions
      // that were pending while the token was fetched.
      if (action.type === REQUEST_TOKEN) {
        const result = next(action)
        for (const task of pendingTasks)
          dispatch(task)
        return result
      }

      // At this point, there is no token yet.
      // We let all action through apart from the action `TASK`, which
      // will be put into a pending queue below.
      if (action.type !== TASK)
        return next(action)

      // At this point a token will be fetched. We track all the dispatched
      // actions as pending until the token is put into store.
      pendingTasks.push(action)

      // Fetch a new token, if one hasn't been fetched yet.
      if (!isGettingToken) {
        isGettingToken = true

        const { request: { projectKey } } = getState()

        const url = buildRequestUrl(httpOptions)
        const requestBody = 'grant_type=client_credentials' +
          `&scope=manage_project:${projectKey}`
        const requestHeaders = Object.assign({}, headers, {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Content-Length': Buffer.byteLength(requestBody),
        })

        const requestOptions = {
          method: 'POST',
          body: requestBody,
          headers: requestHeaders,
          agent,
          timeout,
        }

        return http(url, requestOptions).then(processResponse)
        .then(
          (result) => {
            isGettingToken = false
            // Will dispatch an action to put the token into state.
            // Additionally, all pending tasks will be dispatched as
            // well and handled at the beginning of this middleware.
            dispatch({
              type: REQUEST_TOKEN,
              payload: {
                token: result.body['access_token'],
                expiresIn: result.body['expires_in'],
              },
            })
          },
          (error) => {
            const errorWithRequest = {
              ...error,
              originalRequest: { url, ...requestOptions },
            }
            // Error handling is done in another middleware
            next({
              type: TASK_ERROR,
              meta: action.meta,
              payload: errorWithRequest,
            })
          }
        )
      }

      return null
    }
  }
}


function buildRequestUrl (httpOptions: Object): string {
  const { protocol, host, clientId, clientSecret } = httpOptions
  const authHost = `${protocol}://${clientId}:${clientSecret}@${host}`
  return `${authHost}/oauth/token`
}
