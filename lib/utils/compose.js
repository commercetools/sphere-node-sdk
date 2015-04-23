function hideProperty (obj, key) {
  Object.defineProperty(obj, key, {
    configurable: false,
    enumerable: false,
    writable: false
  })
}

export default function compose () {
  const objects = Array.prototype.slice.call(arguments)
  const composed = objects.reduce((memo, o) => Object.assign(memo, o), {})

  if (composed.request)
    hideProperty(composed, 'request')
  if (composed.options)
    hideProperty(composed, 'options')
  return composed
}
