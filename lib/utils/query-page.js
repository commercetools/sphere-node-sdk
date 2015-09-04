/**
 * Utils `query-page` module. It contains methods to work with paginations.
 * @module utils/queryPage
 */

/**
 * Set the sort expression for the query, if the related endpoint supports it.
 * It is possible to specify several `sort` parameters.
 * In this case they are combined into a composed `sort` where the results
 * are first sorted by the first expression, followed by equal values being
 * sorted according to the second expression, and so on.
 *
 * @param  {string} sortPath - The sort path expression.
 * @param  {boolean} [ascending] - Whether the direction should be
 * ascending or not (default: `true`).
 * @throws If `sortPath` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function sort (sortPath, ascending = true) {
  if (!sortPath)
    throw new Error('Parameter `sortPath` is missing')

  if (sortPath) {
    const direction = ascending ? 'asc' : 'desc'
    const encodedSort = encodeURIComponent(`${sortPath} ${direction}`)
    this.params.pagination.sort.push(encodedSort)
  }
  return this
}

/**
 * Set the page number to be requested from the complete query result
 * (used for pagination as `offset`)
 *
 * @param  {string} page - The page number, greater then zero.
 * @throws If `page` is missing or is a number lesser then one.
 * @return {Object} The instance of the service, can be chained.
 */
export function page (page) {
  if (typeof page !== 'number' && !page)
    throw new Error('Parameter `page` is missing')
  if (typeof page !== 'number' || (typeof page === 'number' && page < 1))
    throw new Error('Parameter `page` must be a number >= 1')

  this.params.pagination.page = page
  return this
}

/**
 * Set the number of results to be returned from a query result
 * (used for pagination as `limit`)
 *
 * @param  {string} perPage - How many results in a page,
 * greater or equals then zero.
 * @throws If `perPage` is missing or is a number lesser then zero.
 * @return {Object} The instance of the service, can be chained.
 */
export function perPage (perPage) {
  if (typeof perPage !== 'number' && !perPage)
    throw new Error('Parameter `perPage` is missing')
  if (typeof perPage !== 'number' ||
    (typeof perPage === 'number' && perPage < 0))
    throw new Error('Parameter `perPage` must be a number >= 0')

  this.params.pagination.perPage = perPage
  return this
}
