/**
 * Given an object, return a clone with non-function properties defined as
 * non-enumerable, unwritable, and unconfigurable.
 *
 * @param {Object}
 * @return {Object}
 */
export default function classify (object) {
  const clone = {}

  for (let key in object)
    Object.defineProperty(clone, key, {
      value: object[key],
      enumerable: typeof object[key] === 'function'
    })

  return clone
}
