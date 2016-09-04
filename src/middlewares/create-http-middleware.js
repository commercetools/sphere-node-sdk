/* global fetch */
import 'isomorphic-fetch'
import buildAbsoluteUrl from '../utils/build-absolute-url'
import buildQueryString from '../utils/build-query-string'
import processResponse from '../utils/process-response'
import {
  TASK,
  TASK_SUCCESS,
  TASK_ERROR,
  HTTP_FETCH,
  HTTP_CREATE,
  HTTP_UPDATE,
  HTTP_DELETE,
  HTTP_GRAPHQL_QUERY,
} from '../constants'

const methodsMap = {
  [HTTP_FETCH]: 'GET',
  [HTTP_CREATE]: 'POST',
  [HTTP_UPDATE]: 'POST',
  [HTTP_DELETE]: 'DELETE',
  [HTTP_GRAPHQL_QUERY]: 'POST',
}

/*
Example of action handled by this middleware:
{
  type: 'TASK',
  meta: {
    source: HTTP_POST,
    promise: { resolve, reject },
    service: 'products',
    serviceState: {...},
  },
  payload: { foo: 'bar' },
}
 */
export default function createHttpMiddleware (options = {}) {
  const {
    host = 'api.sphere.io',
    protocol = 'https',
    agent,
    headers,
    formatAuthorizationHeader = defaultAuthHeader,
    timeout = 20000,
    urlPrefix,
    httpMock,
  } = options

  const http = httpMock || fetch
  const httpOptions = {
    urlPrefix, host, protocol, headers,
    formatAuthorizationHeader, agent, timeout,
  }

  return function httpMiddleware ({ getState }) {
    return next => action => {
      // This is the only action type that should be handled here.
      if (action.type === TASK) {
        // TODO: better action shape validation
        if (
          !action.meta ||
          !action.meta.promise ||
          !action.meta.source ||
          !action.meta.service
        )
          throw new Error('Malformed `TASK` action', action)

        const { meta: { source } } = action

        const url = buildRequestUrl(httpOptions, action, getState)
        const requestHeaders =
          buildRequestHeaders(httpOptions, action, getState)

        const requestBody = (
          source === HTTP_CREATE ||
          source === HTTP_UPDATE ||
          source === HTTP_GRAPHQL_QUERY
        ) ? action.payload : undefined

        const requestOptions = {
          method: methodsMap[source],
          body: requestBody,
          headers: requestHeaders,
          agent, timeout,
        }

        return http(url, requestOptions)
        .then(processResponse)
        .then(
          result => {
            // This is not really necessary as the promise will be resolved
            // at this point. It might be useful to other middlewares down
            // the line though.
            next({
              type: TASK_SUCCESS,
              meta: action.meta,
              payload: result,
            })
            action.meta.promise.resolve(result)
          },
          error => {
            const errorWithRequest = Object.assign({}, error, {
              originalRequest: Object.assign({ url }, requestOptions),
            })
            // Error handling is done in another middleware
            next({
              type: TASK_ERROR,
              meta: action.meta,
              payload: errorWithRequest,
            })
          }
        )
      }

      return next(action)
    }
  }
}


function buildRequestUrl (httpOptions, action, getState) {
  const { meta: { source, serviceState } } = action
  const { request: { projectKey } } = getState()
  const { endpoint, id, ...params } = serviceState

  let finalEndpoint = endpoint

  if (source === HTTP_FETCH) {
    const endpointWithId = id ? `${endpoint}/${id}` : endpoint
    const queryParams = params.customQuery || buildQueryString(params)
    finalEndpoint = withQueryParams(endpointWithId, queryParams)
  }

  if (source === HTTP_CREATE) {
    // Allow to pass expand as a param
    const queryParams = buildQueryString({ expand: params.expand })
    finalEndpoint = withQueryParams(endpoint, queryParams)
  }

  if (source === HTTP_UPDATE) {
    // Allow to pass expand as a param
    const queryParams = buildQueryString({ expand: params.expand })
    finalEndpoint = withQueryParams(`${endpoint}/${id}`, queryParams)
  }

  if (source === HTTP_DELETE) {
    const { payload: version } = action
    finalEndpoint = `${endpoint}/${id}?version=${version}`
  }

  return buildAbsoluteUrl({
    ...httpOptions, projectKey, endpoint: finalEndpoint,
  })
}

function buildRequestHeaders (httpOptions, action, getState) {
  const { headers, formatAuthorizationHeader } = httpOptions
  const { meta: { source }, payload: body } = action
  const { request: { token } } = getState()
  const baseHeaders = { Accept: 'application/json' }

  let httpHeaders = Object.assign({}, baseHeaders, headers)
  let requestBody

  if (
    source === HTTP_CREATE ||
    source === HTTP_UPDATE ||
    source === HTTP_GRAPHQL_QUERY
  ) {
    requestBody = typeof body === 'string'
      ? body : JSON.stringify(body)
    httpHeaders = Object.assign({}, httpHeaders, {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(requestBody),
    })
  }

  if (token)
    httpHeaders = Object.assign({},
      httpHeaders,
      formatAuthorizationHeader(token)
    )

  return httpHeaders
}

function withQueryParams (url, params) {
  if (!params) return url
  return `${url}?${params}`
}

function defaultAuthHeader (token) {
  return { Authorization: `Bearer ${token}` }
}
