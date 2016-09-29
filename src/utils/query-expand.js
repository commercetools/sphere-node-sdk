/* eslint-disable import/prefer-default-export */
import { SERVICE_PARAM_QUERY_EXPAND } from '../constants'

/**
 * Set the
 * [ExpansionPath](http://dev.sphere.io/http-api.html#reference-expansion)
 * used for expanding a
 * [Reference](http://dev.sphere.io/http-api-types.html#reference)
 * of a resource.
 *
 * @param  {string} value - The expand path expression.
 * @throws If `value` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function expand (value) {
  if (!value)
    throw new Error('Required argument for `expand` is missing')

  const encodedPath = encodeURIComponent(value)
  // // Note: this goes to base `params`, not `params.query`
  // // to be compatible with search.
  // this.params.expand.push(encodedPath)
  this.store.dispatch({
    type: SERVICE_PARAM_QUERY_EXPAND,
    meta: { service: this.type },
    payload: encodedPath,
  })
  return this
}
