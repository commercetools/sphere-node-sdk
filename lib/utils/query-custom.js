/**
 * Utils `query-custom` module.
 * @module utils/queryCustom
 */

/**
 * Set a given custom query string. This takes precedence
 * to any other query parameters and only this will be used.
 *
 * @param  {string} customQueryString - A fully encoded URI string.
 * @throws If `customQueryString` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function byQueryString (customQueryString) {
  if (!customQueryString)
    throw new Error('Parameter `customQueryString` is missing')

  this.params.customQuery = customQueryString
  return this
}
