/**
 * Utils `query-custom` module.
 * @module utils/queryCustom
 */

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

  this.params.customQuery = value
  return this
}
