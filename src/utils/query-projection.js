/* eslint-disable import/prefer-default-export */
import { SERVICE_PARAM_QUERY_STAGED } from '../constants'

/**
 * Define whether to get the staged or current projection
 *
 * @param  {boolean} staged - Either `true` (default) or `false`
 * (for current / published)
 * @return {Object} The instance of the service, can be chained.
 */
export function staged (isStaged = true) {
  this.params.staged = isStaged

  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_STAGED,
    meta: { service: this.type },
    payload: isStaged,
  })
  return this
}
