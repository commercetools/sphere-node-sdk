/**
 * Utils `query` module. It contains methods to work with query requests.
 * @module utils/query
 */

/**
 * Set the given `predicate` to the internal state of the service instance.
 *
 * @param  {string} predicate - A non-URI encoded string representing a
 * [Predicate]{@link http://dev.sphere.io/http-api.html#predicates}
 * @throws If `predicate` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function where (predicate) {
  if (!predicate)
    throw new Error('Parameter `predicate` is missing')

  const encodedPredicate = encodeURIComponent(predicate)
  this.params.query.where.push(encodedPredicate)
  return this
}

/**
 * Set the logical operator to combine multiple query predicates
 * {@link module:commons/query.where}
 *
 * @param  {string} operator - A logical operator `and`, `or`
 * @throws If `operator` is missing or has a wrong value.
 * @return {Object} The instance of the service, can be chained.
 */
export function whereOperator (operator) {
  if (!operator)
    throw new Error('Parameter `operator` is missing')
  if (!(operator === 'and' || operator === 'or'))
    throw new Error('Parameter `operator` is wrong, either `and` or `or`')

  this.params.query.operator = operator
  return this
}
