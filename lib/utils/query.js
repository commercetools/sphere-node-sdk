/**
 * Utils `query` module. It contains methods to work with query requests.
 * @module utils/query
 */

/**
 * Set the given `predicate` to the internal state of the service instance.
 *
 * @param  {string} predicate - A non-URI encoded string representing a
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
 * @param  {string} operator - A logical operator `and`, `or`
 * @return {Object} The instance of the service, can be chained.
 */
export function whereOperator (operator) {
  // TODO: throw if operator is wrong?
  if (operator && (operator === 'and' || operator === 'or'))
    this.params.query.operator = operator
  return this
}

/**
 * Set the
 * [ExpansionPath](http://dev.sphere.io/http-api.html#reference-expansion)
 * used for expanding a
 * [Reference](http://dev.sphere.io/http-api-types.html#reference)
 * of a resource.
 *
 * @param  {string} expansionPath - The expand path expression.
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
