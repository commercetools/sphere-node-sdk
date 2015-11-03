export default function createBuildActions (diff, doMapActions) {

  return function buildActions (newObj, oldObj, options = {}) {
    if (!newObj || !oldObj)
      throw new Error('Missing either `newObj` or `oldObj` ' +
        'in order to build update actions')

    // diff 'em
    const diffed = diff(oldObj, newObj)
    if (!diffed) return []

    return doMapActions(diffed, newObj, oldObj, options)
  }
}
