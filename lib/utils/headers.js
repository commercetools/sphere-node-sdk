/**
 * Utils `headers` module.
 * @module utils/headers
 */

/**
 * Set the given `id` to the internal state of the service instance.
 * Allow to add / merge given header with the current ones.
 *
 * @param  {string} key - The header `key`.
 * @param  {string} value - The header `value`.
 * @throws If `key` or `value` are missing.
 * @return {Object} The instance of the service, can be chained.
 */
export function withHeader (key, value) {
  if (arguments.length !== 2)
    throw new Error('Missing required header arguments.')

  Object.assign(this.request.headers, { [key]: value })
  return this
}
