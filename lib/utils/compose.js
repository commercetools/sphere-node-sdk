function hideProperty (obj, key) {
  Object.defineProperty(obj, key, {
    configurable: false,
    enumerable: false,
    writable: false
  })
}

export default function compose () {
  const composed = Object.assign({}, ...arguments)

  for (let key in composed) {
    if (typeof composed[key] !== 'function')
      hideProperty(composed, key)
  }

  return composed
}
