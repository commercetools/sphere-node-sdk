/**
 * Set the given `id` to the internal state of the service instance.
 *
 * @param  {String} id - A resource `UUID`
 * @return {Object} The instance of the service, can be chained.
 */
export function byId (id) {
  // TODO: validate id
  this.params.id = id
  return this
}

/**
 * Set the given `predicate` to the internal state of the service instance.
 *
 * @param  {String} predicate - A non-URI encoded string representing a
 * [Predicate]{@link http://dev.sphere.io/http-api.html#predicates}
 * @return {Object} The instance of the service, can be chained.
 */
export function where (predicate) {
  // TODO: validate predicate
  this.params.where = predicate
  return this
}
