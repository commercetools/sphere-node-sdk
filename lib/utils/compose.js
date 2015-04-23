function hideProperty (obj, key) {
  Object.defineProperty(obj, key, {
    configurable: false,
    enumerable: false,
    writable: false
  })
}

/**
 * Given one-to-many objects, compose them into one object.
 * Also, all non-function properties will be freezed
 * and defined as non-enumerable.
 *
 * @param {Object} arguments
 * @return {Object}
 */
export default function compose () {
  const composed = Object.assign({}, ...arguments)

  for (let key in composed) {
    if (typeof composed[key] !== 'function')
      hideProperty(composed, key)
  }

  return composed
}
