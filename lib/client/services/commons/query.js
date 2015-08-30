/**
 * Commons `query` module. It contains methods to work with query requests.
 * @module commons/query
 */

/**
 * Set the given `predicate` to the internal state of the service instance.
 *
 * @param  {String} predicate - A non-URI encoded string representing a
 * [Predicate]{@link http://dev.sphere.io/http-api.html#predicates}
 * @return {Object} The instance of the service, can be chained.
 */
export function where (predicate) {
  // TODO: throw if predicate is missing?
  if (predicate) {
    const encodedPredicate = encodeURIComponent(predicate)
    this.params.query.where.push(encodedPredicate)
  }
  return this
}

/**
 * Set the logical operator to combine multiple query predicates
 * {@link module:commons/query.where}
 *
 * @param  {String} operator - A logical operator `and`, `or`
 * @return {Object} The instance of the service, can be chained.
 */
export function whereOperator (operator) {
  // TODO: throw if operator is wrong?
  if (operator && (operator === 'and' || operator === 'or'))
    this.params.query.operator = operator
  return this
}

/**
 * Set the sort expression for the query, if the related endpoint supports it.
 * It is possible to specify several `sort` parameters.
 * In this case they are combined into a composed `sort` where the results
 * are first sorted by the first expression, followed by equal values being
 * sorted according to the second expression, and so on.
 *
 * @param  {String} sortPath - The sort path expression.
 * @param  {boolean} [ascending] - Whether the direction should be
 * ascending or not (default: `true`).
 * @return {Object} The instance of the service, can be chained.
 */
export function sort (sortPath, ascending = true) {
  // TODO: throw if sortPath is missing?
  if (sortPath) {
    const direction = ascending ? 'asc' : 'desc'
    const encodedSort = encodeURIComponent(`${sortPath} ${direction}`)
    this.params.query.sort.push(encodedSort)
  }
  return this
}

/**
 * Set the page number to be requested from the complete query result
 * (used for pagination as `offset`)
 *
 * @param  {String} page - The page number, greater then zero.
 * @throws If `page` is a number lesser then one.
 * @return {Object} The instance of the service, can be chained.
 */
export function page (page) {
  // TODO: throw if page is missing?
  if (typeof page !== 'number' || (typeof page === 'number' && page < 1))
    throw new Error('Parameter `page` must be a number >= 1')

  this.params.query.page = page
  return this
}

/**
 * Set the number of results to be returned from a query result
 * (used for pagination as `limit`)
 *
 * @param  {String} perPage - How many results in a page,
 * greater or equals then zero.
 * @throws If `perPage` is a number lesser then zero.
 * @return {Object} The instance of the service, can be chained.
 */
export function perPage (perPage) {
  // TODO: throw if perPage is missing?
  if (typeof perPage !== 'number' ||
    (typeof perPage === 'number' && perPage < 0))
    throw new Error('Parameter `perPage` must be a number >= 0')

  this.params.query.perPage = perPage
  return this
}

/**
 * Set the
 * [ExpansionPath](http://dev.sphere.io/http-api.html#reference-expansion)
 * used for expanding a
 * [Reference](http://dev.sphere.io/http-api-types.html#reference)
 * of a resource.
 *
 * @param  {String} expansionPath - The expand path expression.
 * @return {Object} The instance of the service, can be chained.
 */
export function expand (expansionPath) {
  // TODO: throw if expansionPath is missing?
  if (expansionPath) {
    const encodedPath = encodeURIComponent(expansionPath)
    this.params.query.expand.push(encodedPath)
  }
  return this
}
