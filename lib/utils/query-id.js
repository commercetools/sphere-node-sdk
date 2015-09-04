/**
 * Utils `query-id` module.
 * @module utils/queryId
 */

/**
 * Set the given `id` to the internal state of the service instance.
 *
 * @param  {string} id - A resource `UUID`
 * @throws If `id` is missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function byId (id) {
  if (!id)
    throw new Error('Parameter `id` is missing')

  this.params.id = id
  return this
}
