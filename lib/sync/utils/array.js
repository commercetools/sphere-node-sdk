const hasFind = 'find' in Array.prototype
const hasFindIndex = 'findIndex' in Array.prototype

/**
 * Proxy for `Array.prototype.find`.
 *
 * @param {*[]} array
 * @param {Function} fn
 */
export function find (array, fn) {
  // Check for ES6 `Array.prototype.find`, or fall back to
  // `core-js` polyfill.
  return hasFind ? array.find(fn) : Array.find(...arguments)
}

/**
 * Proxy for `Array.prototype.findIndex`.
 *
 * @param {*[]} array
 * @param {Function} fn
 */
export function findIndex (array, fn) {
  return hasFindIndex ? array.findIndex(fn) : Array.findIndex(array, fn)
}
