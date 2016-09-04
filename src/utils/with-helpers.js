/**
 * Utils `with-helpers` module.
 * @module utils/withHelpers
 */
import {
  REQUEST_TOKEN,
  REQUEST_PROJECT_KEY,
} from '../constants'

/**
 * Allow to override `auth` credentials. Useful for example for
 * changing `projectKey`.
 *
 * @param  {Object} credentials - The new credentials.
 * @throws If `credentials` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function withProject (projectKey) {
  if (!projectKey)
    throw new Error('Project key is missing.')

  this.store.dispatch({
    type: REQUEST_PROJECT_KEY,
    payload: projectKey,
  })
  return this
}

/**
 * Allow to add / merge given header with the current ones.
 *
 * @param  {string} key - The header `key`.
 * @param  {string} value - The header `value`.
 * @throws If `key` or `value` are missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function withToken (token, expiresIn) {
  if (!token)
    throw new Error('Token is missing.')

  this.store.dispatch({
    type: REQUEST_TOKEN,
    payload: { token, expiresIn },
  })
  return this
}
