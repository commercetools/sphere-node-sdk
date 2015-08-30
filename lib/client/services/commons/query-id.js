/**
 * Commons `query-id` module.
 * @module commons/queryId
 */

/**
 * Set the given `id` to the internal state of the service instance.
 *
 * @param  {string} id - A resource `UUID`
 * @return {Object} The instance of the service, can be chained.
 */
export function byId (id) {
  // TODO: throw if id is missing?
  this.params.id = id
  return this
}
