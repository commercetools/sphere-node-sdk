/**
 * Utils `query-projection` module. It contains methods to work with
 * (product) projections.
 * @module utils/queryProjection
 */

/**
 * Define whether to get the staged or current projection
 *
 * @param  {boolean} staged - Either `true` (default) or `false`
 * (for current / published)
 * @return {Object} The instance of the service, can be chained.
 */
export function staged (isStaged = true) {
  this.params.staged = isStaged
  return this
}
