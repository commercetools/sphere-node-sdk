/* eslint-disable import/prefer-default-export */
import { SERVICE_PARAM_QUERY_CUSTOM } from '../constants'

/**
 * Set a given custom query string. This takes precedence
 * to any other query parameters and only this will be used.
 *
 * @param  {string} value - A fully encoded URI string.
 * @throws If `value` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function byQueryString (value) {
  if (!value)
    throw new Error('Required argument for `byQueryString` is missing')

  // this.params.customQuery = value
  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_CUSTOM,
    meta: { service: this.type },
    payload: value,
  })
  return this
}
